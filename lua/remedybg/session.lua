local uv = vim.uv
local remedybg = {
	io = require("remedybg.io"),
}
require("remedybg.commands")
require("remedybg.events")

local enum = require("plenary.enum")

local RDBG_PREFIX = "\\\\.\\pipe\\test"
local RDBG_EVENTS = "\\\\.\\pipe\\test-events"

local event_parsers = {

	-- A target being debugged has exited.
	--
	-- [exit_code :: uint32_t]
	[RDBG_DEBUG_EVENTS.EXIT_PROCESS] = {
		parse = function(data)
			local exit_code
			exit_code, data = remedybg.io.pop_uint32(data)
			return { exit_code = exit_code }, data
		end,
	},

	-- The target for the active configuration is now being debugged.
	--
	-- [process_id :: uint32_t]
	[RDBG_DEBUG_EVENTS.TARGET_STARTED] = {
		parse = function(data)
			local process_id
			process_id, data = remedybg.io.pop_uint32(data)
			return { process_id = process_id }, data
		end,
	},

	-- The debugger has attached to a target process.
	--
	-- [process_id :: uint32_t]
	[RDBG_DEBUG_EVENTS.TARGET_ATTACHED] = {
		parse = function(data)
			local process_id
			process_id, data = remedybg.io.pop_uint32(data)
			return { process_id = process_id }, data
		end,
	},

	-- The debugger has detached from a target process.
	--
	-- [process_id :: uint32_t]
	[RDBG_DEBUG_EVENTS.TARGET_DETACHED] = {
		parse = function(data)
			local process_id
			process_id, data = remedybg.io.pop_uint32(data)
			return { process_id = process_id }, data
		end,
	},

	-- The debugger has transitioned from suspended to executing.
	--
	-- [process_id :: uint32_t]
	[RDBG_DEBUG_EVENTS.TARGET_CONTINUED] = {
		parse = function(data)
			local process_id
			process_id, data = remedybg.io.pop_uint32(data)
			return { process_id = process_id }, data
		end,
	},

	-- The source location changed due to an event in the debugger.
	--
	-- [filename :: rdbg_String]
	-- [line_num :: uint32_t]
	-- [reason :: rdbg_SourceLocChangedReason (uint16_t) ]
	[RDBG_DEBUG_EVENTS.SOURCE_LOCATION_CHANGED] = {
		parse = function(data)
			local file
			file, data = remedybg.io.pop_string(data)
			local line
			line, data = remedybg.io.pop_uint32(data)
			local reason
			reason, data = remedybg.io.pop_uint16(data)
			return { filename = file, line_num = line, reason = reason }, data
		end,
	},

	-- A user breakpoint was hit
	--
	-- [kind :: rdbg_DebugEventKind (uint16_t)]
	-- [bp_id :: rdbg_Id]
	[RDBG_DEBUG_EVENTS.BREAKPOINT_HIT] = {
		parse = function(data)
			local bp_id
			bp_id, data = remedybg.io.pop_uint32(data)
			return { bp_id = bp_id }, data
		end,
	},

	-- The breakpoint with the given ID has been resolved (has a valid location).
	-- This can happen if the breakpoint was set in module that became loaded,
	-- for instance.
	--
	-- [bp_id :: rdbg_Id]
	[RDBG_DEBUG_EVENTS.BREAKPOINT_RESOLVED] = {
		parse = function(data)
			local bp_id
			bp_id, data = remedybg.io.pop_uint32(data)
			return { bp_id = bp_id }, data
		end,
	},

	-- A new user breakpoint was added.
	--
	-- [bp_id :: rdbg_Id]
	[RDBG_DEBUG_EVENTS.BREAKPOINT_ADDED] = {
		parse = function(data)
			local bp_id
			bp_id, data = remedybg.io.pop_uint32(data)
			return { bp_id = bp_id }, data
		end,
	},

	-- A user breakpoint was modified.
	--
	-- [bp_id :: rdbg_Id]
	[RDBG_DEBUG_EVENTS.BREAKPOINT_MODIFIED] = {
		parse = function(data)
			local bp_id
			bp_id, data = remedybg.io.pop_uint32(data)
			return { bp_id = bp_id }, data
		end,
	},

	-- A user breakpoint was removed.
	--
	-- [bp_id :: rdbg_Id]
	[RDBG_DEBUG_EVENTS.BREAKPOINT_REMOVED] = {
		parse = function(data)
			local bp_id
			bp_id, data = remedybg.io.pop_uint32(data)
			return { bp_id = bp_id }, data
		end,
	},

	-- An OutputDebugString was received by the debugger. The given string will
	-- be UTF-8 encoded.
	--
	-- [str :: rdbg_String]
	[RDBG_DEBUG_EVENTS.OUTPUT_DEBUG_STRING] = {
		parse = function(data)
			local str
			str, data = remedybg.io.pop_string(data)
			return { str = str }, data
		end,
	},
}

--- @enum state
local state = enum({
	"CONNECTING",
	"CONNECTED",
	"ERROR",
})

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
}
local commands = require("remedybg.session.commands")

function session:new(executable_command)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.process = uv.spawn("remedybg.exe", { args = { "--servername test", executable_command }, verbatim = true })

	o.timer = uv.new_timer()
	o.timer:start(1000, 1000, function()
		o:loop()
	end)

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

function session:write_command(cmd, args)
	if not self.current_session then
		return
	end
	local command = commands[cmd]
	if not command then
		return
	end

	self.current_session:write(command.pack(args))
	local output
	self.current_session:read_start(function(_, data)
		if data then
			local res
			res, data = remedybg.io.pop_uint16(data)
			if res == 1 then
				output = command.read(data)
			end
		end
	end)

	return output
end

function session:loop()
	if self.process and not self.process:is_active() then
		self.timer:stop()

		if self.current_session and self.current_session:is_active() then
			self.current_session:close()
		end

		if self.event_pipe and self.event_pipe:is_active() then
			self.event_pipe:close()
		end

		return
	end

	if self.state == state.CONNECTING then
		if self:try_connect() then
			self.state = state.CONNECTED
		end
	elseif self.state == state.CONNECTED then
		assert(self.event_pipe, "Event pipe shouldn't be nil")

		self.event_pipe:read_start(function(_, data)
			while data and data:len() > 0 do
				-- todo: handle split buffers
				-- todo: log
				local cmd
				cmd, data = remedybg.io.pop_uint16(data)
				local res
				res, data = event_parsers[cmd].parse(data)
				-- todo: log

				-- todo: proper callbacks
				if cmd == RDBG_DEBUG_EVENTS.SOURCE_LOCATION_CHANGED then
					vim.schedule(function()
						-- todo: open buffer if it doesn't exist and navigate within the buffer
						vim.cmd("e +" .. res.line_num .. " " .. res.filename)
					end)
				end
			end
		end)
	end
end

function session:start_debugging(break_at_entry_point)
	self:write_command(RDBG_COMMANDS.START_DEBUGGING, { break_at_entry_point = break_at_entry_point })
end

function session:step_into()
	self:write_command(RDBG_COMMANDS.STEP_INTO_BY_LINE, {})
end

function session:step_over()
	self:write_command(RDBG_COMMANDS.STEP_OVER_BY_LINE, {})
end

return session
