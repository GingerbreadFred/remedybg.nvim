local uv = vim.uv
local remedybg = {
	io = require("remedybg.io"),
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
}

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

	-- TODO: handle session destruction and unregister callback
	o.breakpoints:on_breakpoint_added(function(breakpoint)
		o:write_command(
			RDBG_COMMANDS.ADD_BREAKPOINT_AT_FILENAME_LINE,
			{ filename = breakpoint.file, line_num = breakpoint.line }
		)
	end)

	o.breakpoints:on_breakpoint_removed(function(breakpoint)
		o:write_command(RDBG_COMMANDS.DELETE_BREAKPOINT, { bp_id = breakpoint.remedybg_id })
	end)

	o.event_queue = event_queue:new()

	return o
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
end

function session:loop()
	if self.process and not self.process:is_active() then
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
						local all_buffers = vim.api.nvim_list_bufs()
						local current_win = vim.api.nvim_get_current_win()

						for _, v in pairs(all_buffers) do
							if vim.api.nvim_buf_get_name(v) == res.filename then
								vim.api.nvim_win_set_buf(current_win, v)
								vim.api.nvim_win_set_cursor(current_win, { res.line_num, 0 })
								return
							end
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
				end
			end
		end)
	end
end

--- @param break_at_entry_point boolean
function session:start_debugging(break_at_entry_point)
	self:write_command(RDBG_COMMANDS.START_DEBUGGING, { break_at_entry_point = break_at_entry_point })
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

return session
