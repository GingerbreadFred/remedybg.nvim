local uv = vim.uv
local remedybg = {
	io = require("remedybg.io"),
	util = require("remedybg.util"),
}
require("remedybg.commands")
require("remedybg.events")

local commands = require("remedybg.session.commands")
local events = require("remedybg.session.events")

-- TODO: create unique names
local RDBG_PREFIX = "\\\\.\\pipe\\test"
local RDBG_EVENTS = "\\\\.\\pipe\\test-events"

--- @enum state
local state = {
	CONNECTING = 0,
	SETUP = 1,
	CONNECTED = 2,
	ERROR = 3,
}

--- @class stack_frame_indicator
local stack_frame_indicator = {
	sign_id = nil,
	filename = "",
	line_num = 0,
	--- @type breakpoints
	breakpoints = nil,
	on_breakpoint_added = nil,
	on_breakpoint_removed = nil,
}

function stack_frame_indicator:new(breakpoints)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.breakpoints = breakpoints
	o.on_breakpoint_added = function(breakpoint)
		if o.filename == breakpoint.file and o.line_num == breakpoint.line then
			local buffer = remedybg.util.get_buffer_for_filename(o.filename)
			o:place(buffer, true)
		end
	end

	o.breakpoints:on_breakpoint_added(o.on_breakpoint_added)

	o.on_breakppont_removed = function(breakpoint)
		if o.filename == breakpoint.file then
			local buffer = remedybg.util.get_buffer_for_filename(o.filename)
			o:place(buffer, false)
		end
	end

	o.breakpoints:on_breakpoint_removed(o.on_breakppont_removed)

	return o
end

function stack_frame_indicator:place(buffer, is_breakpoint)
	self:remove()
	if buffer then
		local sign_name = is_breakpoint and "stack_frame_indicator_with_breakpoint" or "stack_frame_indicator"
		local sign_id = self.sign_id or 0
		self.sign_id = vim.fn.sign_place(sign_id, "stack_frame_indicator", sign_name, buffer, { lnum = self.line_num })
	end
end

function stack_frame_indicator:update_file_line(filename, line_num)
	self.filename = filename
	self.line_num = line_num

	local buffer = remedybg.util.get_buffer_for_filename(filename)

	if buffer then
		local is_breakpoint = false
		for _, v in pairs(self.breakpoints:get_breakpoints()) do
			if v.file == filename and v.line == line_num then
				is_breakpoint = true
				break
			end
		end
		self:place(buffer, is_breakpoint)
	end
end

function stack_frame_indicator:remove()
	if self.sign_id then
		vim.fn.sign_unplace("stack_frame_indicator", { id = self.sign_id })
		self.sign_id = nil
	end
end

function stack_frame_indicator:on_buffer_loaded(buffer)
	local filename = vim.api.nvim_buf_get_name(buffer)

	if filename == self.filename then
		self:place(buffer)
	end
end

function stack_frame_indicator:cleanup()
	self:remove()
	self.breakpoints:remove_on_breakpoint_added(self.on_breakpoint_added)
	self.breakpoints:remove_on_breakpoint_removed(self.on_breakpoint_removed)
end

--- @class event_queue
local event_queue = {
	--- @type function[]
	events = {},
	--- @type boolean
	busy = false,
}

function event_queue:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self

	return o
end

function event_queue:run()
	if not self.busy then
		local num = table.getn(events)
		if num == 0 then
			return
		end
		local first = events[1]
		self.busy = true
		table.remove(events, 1)

		first()
	end
end

function event_queue:release()
	self.busy = false
end

function event_queue:enqueue(func)
	if not self.busy then
		self.busy = true
		func()
	else
		table.insert(events, func)
	end
end

--- @class session
local session = {
	--- @type uv_pipe_t?
	current_session = nil,
	--- @type uv_pipe_t?
	event_pipe = nil,
	--- @type uv_timer_t?
	timer = nil,
	--- @type uv_process_t?
	process = nil,
	--- @type state
	state = state.CONNECTING,
	--- @type breakpoints
	breakpoints = nil,
	--- @type event_queue
	event_queue = nil,
	--- @type stack_frame_indicator
	stack_frame_indicator = nil,
	on_breakpoint_added = nil,
	on_breakpoint_removed = nil,
}

function session.setup()
	vim.fn.sign_define("stack_frame_indicator", { text = ">", texthl = "", linehl = "", numhl = "" })
	vim.fn.sign_define("stack_frame_indicator_with_breakpoint", { text = "B>", texthl = "", linehl = "", numhl = "" })
end

--- @param executable_command string
--- @param breakpoints breakpoints
function session:new(executable_command, breakpoints)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.process = uv.spawn("remedybg.exe", { args = { "--servername test", executable_command }, verbatim = true })

	o.timer = uv.new_timer()
	o.timer:start(1000, 1000, function()
		o:loop()
	end)

	o.breakpoints = breakpoints

	o.on_breakpoint_added = function(breakpoint, added_remotely)
		--- if the breakpoint was added locally then notify remedy_bg
		if not added_remotely then
			o:write_command(
				RDBG_COMMANDS.ADD_BREAKPOINT_AT_FILENAME_LINE,
				{ filename = breakpoint.file, line_num = breakpoint.line }
			)
		end
	end

	o.on_breakpoint_removed = function(breakpoint, removed_remotely)
		if not removed_remotely then
			o:write_command(RDBG_COMMANDS.DELETE_BREAKPOINT, { bp_id = breakpoint.remedybg_id })
		end
	end

	-- TODO: handle session destruction and unregister callback
	o.breakpoints:on_breakpoint_added(o.on_breakpoint_added)
	o.breakpoints:on_breakpoint_removed(o.on_breakpoint_removed)

	o.event_queue = event_queue:new()

	o.stack_frame_indicator = stack_frame_indicator:new(breakpoints)

	return o
end

function session:is_active()
	return self.process and self.process:is_active()
end

function session:try_connect()
	if not (self.current_session and self.current_session:is_active()) then
		self.current_session = uv.new_pipe()
		self.current_session:connect(RDBG_PREFIX, function(err)
			if err then
				self.current_session:close()
			end
		end)
	end
	if not (self.event_pipe and self.event_pipe:is_active()) then
		self.event_pipe = uv.new_pipe()
		self.event_pipe:connect(RDBG_EVENTS, function(err)
			if err then
				self.event_pipe:close()
			end
		end)
	end

	return self.current_session:is_active() and self.event_pipe:is_active()
end

---@param cmd RDBG_COMMANDS
---@param args table
function session:write_command(cmd, args, callback)
	local command = commands[cmd]

	if not command then
		return
	end

	if not self.current_session then
		return
	end

	self.event_queue:enqueue(function()
		self.current_session:write(command.pack(args))
		self.current_session:read_start(function(_, data)
			if data then
				local res
				res, data = remedybg.io.pop_uint16(data)
				if res == 1 then
					local output = command.read(data)
					if callback then
						callback(output)
					end
				end
			end
			self.event_queue:release()
		end)
	end)
end

function session:cleanup()
	self.timer:stop()

	if self.current_session and self.current_session:is_active() then
		self.current_session:close()
	end

	if self.event_pipe and self.event_pipe:is_active() then
		self.event_pipe:close()
	end

	self.breakpoints:on_debugger_terminated()
	self.breakpoints:remove_on_breakpoint_added(self.on_breakpoint_added)
	self.breakpoints:remove_on_breakpoint_removed(self.on_breakpoint_removed)
	self.stack_frame_indicator:cleanup()
end

function session:loop()
	if not self:is_active() then
		self:cleanup()
		return
	end

	if self.state == state.CONNECTING then
		if self:try_connect() then
			self.state = state.SETUP
		end
	elseif self.state == state.SETUP then
		-- add all the breakpoints we created offline
		for _, v in pairs(self.breakpoints:get_breakpoints()) do
			self:write_command(RDBG_COMMANDS.ADD_BREAKPOINT_AT_FILENAME_LINE, { filename = v.file, line_num = v.line })
		end
		self:write_command(RDBG_COMMANDS.START_DEBUGGING, { break_at_entry_point = true })
		self.state = state.CONNECTED
	elseif self.state == state.CONNECTED then
		assert(self.event_pipe, "Event pipe shouldn't be nil")

		self.event_queue:run()
		self.event_pipe:read_start(function(_, data)
			while data and data:len() > 0 do
				-- TODO: handle split buffers
				-- TODO: log
				local cmd
				cmd, data = remedybg.io.pop_uint16(data)
				local res
				res, data = events[cmd].parse(data)
				-- TODO: proper callbacks
				if cmd == RDBG_DEBUG_EVENTS.SOURCE_LOCATION_CHANGED then
					vim.schedule(function()
						local current_win = vim.api.nvim_get_current_win()
						local buffer = remedybg.util.get_buffer_for_filename(res.filename)

						self.stack_frame_indicator:update_file_line(res.filename, res.line_num)

						if buffer then
							vim.api.nvim_win_set_buf(current_win, buffer)
							vim.api.nvim_win_set_cursor(current_win, { res.line_num, 0 })
							return
						end

						-- buffer is not open, so let's open it
						vim.cmd("e +" .. res.line_num .. " " .. res.filename)
					end)
				elseif cmd == RDBG_DEBUG_EVENTS.BREAKPOINT_ADDED then
					local bp_id = res.bp_id
					vim.schedule(function()
						self:get_breakpoint(bp_id, function(bp_info)
							vim.schedule(function()
								self.breakpoints:on_breakpoint_added_remotely(
									bp_info.info.filename,
									bp_info.info.line_num,
									bp_id
								)
							end)
						end)
					end)
				elseif cmd == RDBG_DEBUG_EVENTS.BREAKPOINT_REMOVED then
					local bp_id = res.bp_id
					vim.schedule(function()
						self.breakpoints:on_breakpoint_removed_remotely(bp_id)
					end)
				elseif cmd == RDBG_DEBUG_EVENTS.EXIT_PROCESS then
					vim.schedule(function()
						self.process:kill()
					end)
				elseif cmd == RDBG_DEBUG_EVENTS.TARGET_CONTINUED then
					vim.schedule(function()
						self.stack_frame_indicator:remove()
					end)
				end
			end
		end)
	end
end

function session:step_into()
	self:write_command(RDBG_COMMANDS.STEP_INTO_BY_LINE, {})
end

function session:step_over()
	self:write_command(RDBG_COMMANDS.STEP_OVER_BY_LINE, {})
end

function session:step_out()
	self:write_command(RDBG_COMMANDS.STEP_OUT, {})
end

function session:get_breakpoint(bp_id, callback)
	self:write_command(RDBG_COMMANDS.GET_BREAKPOINT, { bp_id = bp_id }, callback)
end

function session:continue_execution()
	self:write_command(RDBG_COMMANDS.CONTINUE_EXECUTION, {})
end

function session:on_buffer_loaded(buffer)
	self.stack_frame_indicator:on_buffer_loaded(buffer)
end

return session
