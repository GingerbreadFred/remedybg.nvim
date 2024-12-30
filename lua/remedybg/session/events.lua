require("remedybg.events")
local remedybg = {
	io = require("remedybg.io"),
}

return {

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
