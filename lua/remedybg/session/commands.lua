require("remedybg.commands")
require("remedybg.breakpoint_kind")
local remedybg = {
	io = require("remedybg.io"),
}
local struct = require("struct")

return {
	-- Bring the RemedyBG window to the foreground and activate it. No additional
	-- arguments follow the command. Returns RESULT_OK or
	-- RESULT_FAIL.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.BRING_DEBUGGER_TO_FOREGROUND] = {
		pack = function(_)
			return struct.pack("H", RDBG_COMMANDS.BRING_DEBUGGER_TO_FOREGROUND)
		end,
		read = function(_) end,
	},

	-- Set the size and position of the RemedyBG window.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [x :: int32_t]
	-- [y :: int32_t]
	-- [width :: int32_t]
	-- [height :: int32_t]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.SET_WINDOW_POS] = nil,

	-- Get the size and position of the RemedyBG window.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [x :: int32_t]
	-- [y :: int32_t]
	-- [width :: int32_t]
	-- [height :: int32_t]
	-- [is_maximized: rdbg_Bool]
	[RDBG_COMMANDS.GET_WINDOW_POS] = nil,

	-- Set whether to automatically bring the debugger to the foreground whenever
	-- the target is suspended (breakpoint hit, exception, single-step complete,
	-- etc.). Defaults to true if not set.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [bring_to_foreground_on_suspended :: rdbg_Bool (uint8_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.SET_BRING_TO_FOREGROUND_ON_SUSPENDED] = nil,

	-- Exit the RemedyBG application.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [dtb :: rdbg_DebuggingTargetBehavior (uint8_t)]
	-- [msb :: rdbg_ModifiedSessionBehavior (uint8_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.EXIT_DEBUGGER] = nil,

	-- Session
	--

	-- Returns whether the current session is modified, or "dirty".
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [modified :: rdbg_Bool (uint8_t)]
	[RDBG_COMMANDS.GET_IS_SESSION_MODIFIED] = nil,

	-- Returns the current session's filename. If the filename has not been set
	-- for the session then the result will be
	-- RESULT_UNNAMED_SESSION and the length of |filename| will be
	-- zero.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [filename :: rdbg_String]
	[RDBG_COMMANDS.GET_SESSION_FILENAME] = nil,

	-- Creates a new session. All configurations are cleared and reset.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [dtb :: rdbg_DebuggingTargetBehavior (uint8_t)]
	-- [msb :: rdbg_ModifiedSessionBehavior (uint8_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.NEW_SESSION] = nil,

	-- Open a session with the given filename.
	--
	-- [command :: rdbg_Command (uint16_t)]
	-- [dtb :: rdbg_DebuggingTargetBehavior (uint8_t)]
	-- [msb :: rdbg_ModifiedSessionBehavior (uint8_t)]
	-- [filename :: rdbg_String]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.OPEN_SESSION] = nil,

	-- Save session with its current filename. If the filename is has not been
	-- specified for the session the user will be prompted. To save with a
	-- filename see SAVE_AS_SESSION, instead.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.SAVE_SESSION] = nil,

	-- Save session with a given filename.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [filename :: rdbg_String]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.SAVE_AS_SESSION] = nil,

	-- Retrieve a list of configurations for the current session.
	--
	-- [cmd :: rdbg_Command (uint16_t)
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [num_configs :: uint16_t]
	-- .FOR(num_configs) {
	--   [uid :: rdbg_Id (uint32_t)]
	--   [command :: rdbg_String]
	--   [command_args :: rdbg_String]
	--   [working_dir :: rdbg_String]
	--   [environment_vars :: rdbg_String]
	--   [inherit_environment_vars_from_parent :: rdbg_Bool]
	--   [break_at_nominal_entry_point :: rdbg_Bool]
	--   [name :: rdbg_String]
	-- }
	[RDBG_COMMANDS.GET_SESSION_CONFIGS] = nil,

	-- Add a new session configuration to the current session. All string
	-- parameters accept zero length strings. Multiple environment variables
	-- should be newline, '\n', separated. Returns the a unique ID for the
	-- configuration.
	--
	-- Note that 'name' is currently optional.
	--
	-- [cmd :: rdbg_Command (uint16_t)
	-- [command :: rdbg_String]
	-- [command_args :: rdbg_String]
	-- [working_dir :: rdbg_String]
	-- [environment_vars :: rdbg_String]
	-- [inherit_environment_vars_from_parent :: rdbg_Bool]
	-- [break_at_nominal_entry_point :: rdbg_Bool]
	-- [name :: rdbg_String]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [uid :: rdbg_Id]
	[RDBG_COMMANDS.ADD_SESSION_CONFIG] = nil,

	-- Sets the active configuration for a session by configuration ID. If the
	-- ID is not valid for the current session
	-- RESULT_INVALID_ID is returned.
	--
	-- [cmd :: rdbg_Command (uint16_t)
	-- [id  :: rdbg_Id]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.SET_ACTIVE_SESSION_CONFIG] = nil,

	-- Deletes a session configuration by ID. If the ID is not valid for the
	-- current session REMOVE_SESSION_CONFIG is returned.
	--
	-- [cmd :: rdbg_Command (uint16_t)
	-- [id  :: rdbg_Id]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.DELETE_SESSION_CONFIG] = nil,

	-- Deletes all session configurations in the current session.
	--
	-- [cmd :: rdbg_Command (uint16_t)
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.DELETE_ALL_SESSION_CONFIGS] = {
		pack = function(_)
			return struct.pack("H", RDBG_COMMANDS.DELETE_ALL_SESSION_CONFIGS)
		end,
		read = function(_) end,
	},
	-- Source Files
	--

	-- Opens the given file, if not already opened, and navigates to the
	-- specified line number. The line number is optional and can be elided from
	-- the command buffer. Returns result along with an ID for the file.
	--
	-- [cmd :: rdbg_Command (uint16_t)
	-- [filename :: rdbg_String]
	-- [line_num :: uint32_t]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [id :: rdbg_Id]
	[RDBG_COMMANDS.GOTO_FILE_AT_LINE] = nil,

	-- Close the file with the given ID.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [id :: rdbg_Id]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.CLOSE_FILE] = nil,

	-- Close all open files
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.CLOSE_ALL_FILES] = nil,

	-- Returns the current file. If no file is open, returns a zero ID,
	-- zero-length filename, and zero line number.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [id :: rdbg_Id]
	-- [filename :: rdbg_String]
	-- [line_num :: uint32_t]
	[RDBG_COMMANDS.GET_CURRENT_FILE] = nil,

	-- Retrieve a list of open files.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [num_files :: uint16_t]
	-- .FOR(num_files) {
	--   [id :: rdbg_Id]
	--   [filename :: rdbg_String]
	--   [line_num :: uint32_t]
	-- }
	[RDBG_COMMANDS.GET_OPEN_FILES] = nil,

	--
	-- Debugger Control

	-- Returns the target state for the current session.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [staste :: rdbg_TargetState (uint16_t)]
	[RDBG_COMMANDS.GET_TARGET_STATE] = nil,

	-- If the target is stopped, i.e., not currently being debugged, then start
	-- debugging the active configuration. Setting break_at_entry to true will
	-- stop execution at the at entry point specified in the configuration:
	-- either the nominal entry point, such as "main" or "WinMain" or the entry
	-- point function as described in the PE header. If the target is already
	-- being debugged, this will return RESULT_INVALID_TARGET_STATE.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [break_at_entry_point :: rdbg_Bool (uint8_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.START_DEBUGGING] = {
		pack = function(args)
			return struct.pack("HB", RDBG_COMMANDS.START_DEBUGGING, args.break_at_entry_point and 1 or 1)
		end,
		read = function(_) end,
	},
	-- Stop debugging the target. If the target is not executing this will return
	-- RESULT_INVALID_TARGET_STATE.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.STOP_DEBUGGING] = nil,

	-- Restart debugging if the target is being debugging (either suspended or
	-- executing) and the target was not attached to a process. Otherwise,
	-- returns RESULT_INVALID_TARGET_STATE.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.RESTART_DEBUGGING] = nil,

	-- Attach to a process by the given process-id. The of
	-- |continue_execution| indicates whether the process should resume execution
	-- after attached.  The debugger target behavior specifies what should happen
	-- in the case when the target is being debugged (suspended or executing).
	-- Can return: RESULT_OK, RDBG_COMMAND_RESULT_FAIL, or
	-- RESULT_ABORT.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [process_id :: uint32_t]
	-- [continue_execution :: rdbg_Bool]
	-- [dtb :: rdbg_DebuggingTargetBehavior (uint8_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.ATTACH_TO_PROCESS_BY_PID] = nil,

	-- Attach to a process by the given name. The first process found, in the
	-- case there are more than one with the same name, is used. The of
	-- |continue_execution| indicates whether the process should resume execution
	-- after attached.  The debugger target behavior specifies what should happen
	-- in the case when the target is being debugged (suspended or executing).
	-- Can return: RESULT_OK, RDBG_COMMAND_RESULT_FAIL, or
	-- RESULT_ABORT.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [process_name :: rdbg_String]
	-- [continue_execution :: rdbg_Bool]
	-- [dtb :: rdbg_DebuggingTargetBehavior (uint8_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.ATTACH_TO_PROCESS_BY_NAME] = nil,

	-- Detach from a target that is being debugged. Can return
	-- RESULT_OK or RDBG_COMMAND_RESULT_INVALID_TARGET_STATE.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.DETACH_FROM_PROCESS] = nil,

	-- With the target suspended, step into by line. If a function call occurs,
	-- this command will enter the function.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.STEP_INTO_BY_LINE] = {
		pack = function(_)
			return struct.pack("H", RDBG_COMMANDS.STEP_INTO_BY_LINE)
		end,
		read = function(_) end,
	},
	-- With the target suspended, step into by instruction. If a function call
	-- occurs, this command will enter the function. Can return
	-- RESULT_OK or RDBG_COMMAND_RESULT_INVALID_TARGET_STATE.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.STEP_INTO_BY_INSTRUCTION] = nil,

	-- With the target suspended, step into by line. If a function call occurs,
	-- this command step over that function and not enter it. Can return
	-- return RESULT_OK or RDBG_COMMAND_RESULT_INVALID_TARGET_STATE.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.STEP_OVER_BY_LINE] = {
		pack = function(_)
			return struct.pack("H", RDBG_COMMANDS.STEP_OVER_BY_LINE)
		end,
		read = function(_) end,
	},
	-- With the target suspended, step into by instruction. If a function call
	-- occurs, this command will step over that function and not enter it. Can
	-- return RESULT_OK or RDBG_COMMAND_RESULT_INVALID_TARGET_STATE.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.STEP_OVER_BY_INSTRUCTION] = nil,

	-- With the target suspended, continue running to the call site of the
	-- current function, i.e., step out.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.STEP_OUT] = {
		pack = function(_)
			return struct.pack("H", RDBG_COMMANDS.STEP_OUT)
		end,
		read = function(_) end,
	},
	-- With the target suspended, continue execution. Can return
	-- RESULT_OK or RDBG_COMMAND_RESULT_INVALID_TARGET_STATE.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.CONTINUE_EXECUTION] = nil,

	-- When the target is not being debugged or is suspended, run to the given
	-- filename and line number.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [filename :: rdbg_String]
	-- [line_num :: uint32_t]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.RUN_TO_FILE_AT_LINE] = nil,

	-- Halt the execution of a target that is in the executing state. Can return
	-- RESULT_OK or RDBG_COMMAND_RESULT_INVALID_TARGET_STATE.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.BREAK_EXECUTION] = nil,

	--
	-- Breakpoints

	-- Return the current list of breakpoints. These are the user requested
	-- breakpoints. Resolved breakpoint locations, if any, for a requested
	-- breakpoint can be obtained using GET_BREAKPOINT_LOCATIONS.
	--
	--  * Presently, module name is not used and will always be a zero length
	--  string.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [num_bps :: uint16_t]
	-- .FOR(num_bps) {
	--   [uid :: rdbg_Id]
	--   [enabled :: rdbg_Bool]
	--   [module_name :: rdbg_String]
	--   [condition_expr :: rdbg_String]
	--   [kind :: rdbg_BreakpointKind (uint8_t)]
	--   .SWITCH(kind) {
	--     .CASE(BreakpointKind_FunctionName):
	--       [function_name :: rdbg_String]
	--       [overload_id :: uint32_t]
	--     .CASE(BreakpointKind_FilenameLine):
	--       [filename :: rdbg_String]
	--       [line_num :: uint32_t]
	--     .CASE(BreakpointKind_Address):
	--       [address :: uint64_t]
	--     .CASE(BreakpointKind_Processor):
	--       [addr_expression :: rdbg_String]
	--       [num_bytes :: uint8_t]
	--       [access_kind :: rdbg_ProcessorBreakpointAccessKind (uint8_t)]
	--   }
	-- }
	[RDBG_COMMANDS.GET_BREAKPOINTS] = nil,

	-- Return the list of resolved locations for a particular breakpoint. If the
	-- ID is not valid for the current session RESULT_INVALID_ID is
	-- returned.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [bp_id :: rdbg_Id]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [num_locs :: uint16_t]
	-- .FOR(num_locs) {
	--   [address :: uint64_t]
	--   [module_name :: rdbg_String]
	--   [filename :: rdbg_String]
	--   [actual_line_num :: uint32_t]
	-- }
	[RDBG_COMMANDS.GET_BREAKPOINT_LOCATIONS] = nil,

	-- Return a list of function overloads for the given function name. If the
	-- target is being debugged (suspended or executing) then returns a list of
	-- function overloads for the given function name, otherwise
	-- RESULT_INVALID_TARGET_STATE is returned. Note that,
	-- presently, all modules are searched for the given function.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [function_name :: rdbg_String]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [num_overloads :: uint8_t]
	-- .FOR(num_overloads) {
	--   [overload_id :: rdbg_Id]
	--   [signature :: rdbg_String]
	-- }
	[RDBG_COMMANDS.GET_FUNCTION_OVERLOADS] = nil,

	-- Request a breakpoint at the given function name and overload. Pass an
	-- overload ID of zero to add requested breakpoints for all functions with
	-- the given name.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [function_name :: rdbg_String]
	-- [overload_id :: rdbg_Id]
	-- [condition_expr :: rdbg_String]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [bp_id :: rdbg_Id]
	[RDBG_COMMANDS.ADD_BREAKPOINT_AT_FUNCTION] = nil,

	-- Request a breakpoint at the given source file and line number.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [filename :: rdbg_String]
	-- [line_num :: uint32_t]
	-- [condition_expr :: rdbg_String]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [bp_id :: rdbg_Id]
	[RDBG_COMMANDS.ADD_BREAKPOINT_AT_FILENAME_LINE] = {
		pack = function(args)
			return struct.pack(
				"HHc0IH",
				RDBG_COMMANDS.ADD_BREAKPOINT_AT_FILENAME_LINE,
				string.len(args.filename),
				args.filename,
				args.line_num,
				0
			)
		end,
		read = function(res)
			local output = struct.unpack("I", res)
			return { id = output[1] }
		end,
	},
	-- Request a breakpoint at the given address.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [address :: uint64_t]
	-- [condition_expr :: rdbg_String]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [bp_id :: rdbg_Id]
	[RDBG_COMMANDS.ADD_BREAKPOINT_AT_ADDRESS] = nil,

	-- Add a processor (hardware) breakpoint.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [addr_expression :: rdbg_String]
	-- [num_bytes :: uint8_t]
	-- [access_kind :: rdbg_ProcessorBreakpointAccessKind (uint8_t)]
	-- [condition_expr :: rdbg_String]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [bp_id :: rdbg_Id]
	[RDBG_COMMANDS.ADD_PROCESSOR_BREAKPOINT] = nil,

	-- Sets the conditional expression for the given breakpoint. Can pass in a
	-- zero-length string for none.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [bp_id :: rdbg_Id]
	-- [condition_expr :: rdbg_String]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.SET_BREAKPOINT_CONDITION] = nil,

	-- Given an existing breakpoint of type RDBG_BREAKPOINT_KIND_FILENAME_LINE,
	-- update its line number to the given one-based.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [bp_id :: rdbg_Id]
	-- [line_num :: uint32_t]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.UPDATE_BREAKPOINT_LINE] = nil,

	-- Enable or disable an existing breakpoint.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [bp_id :: rdbg_Id]
	-- [enable :: rdbg_Bool]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.ENABLE_BREAKPOINT] = nil,

	-- Delete an existing breakpoint.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [bp_id :: rdbg_Id]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.DELETE_BREAKPOINT] = {
		pack = function(args)
			return struct.pack("HI", RDBG_COMMANDS.DELETE_BREAKPOINT, args.bp_id)
		end,
		read = function(_) end,
	},
	-- Delete all existing breakpoints.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.DELETE_ALL_BREAKPOINTS] = nil,

	-- Return information about a specific user requested breakpoint.
	--
	--  * Presently, module name is not used and will always be a zero length
	--  string.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [bp_id :: rdbg_Id]
	-- =>
	-- [uid :: rdbg_Id]
	-- [enabled :: rdbg_Bool]
	-- [module_name :: rdbg_String]
	-- [condition_expr :: rdbg_String]
	-- [kind :: rdbg_BreakpointKind (uint8_t)]
	-- .SWITCH(kind) {
	--   .CASE(BreakpointKind_FunctionName):
	--     [function_name :: rdbg_String]
	--     [overload_id :: uint32_t]
	--   .CASE(BreakpointKind_FilenameLine):
	--     [filename :: rdbg_String]
	--     [line_num :: uint32_t]
	--   .CASE(BreakpointKind_Address):
	--     [address :: uint64_t]
	--   .CASE(BreakpointKind_Processor):
	--     [addr_expression :: rdbg_String]
	--     [num_bytes :: uint8_t]
	--     [access_kind :: rdbg_ProcessorBreakpointAccessKind (uint8_t)]
	-- }
	[RDBG_COMMANDS.GET_BREAKPOINT] = {
		pack = function(args)
			return struct.pack("HI", RDBG_COMMANDS.GET_BREAKPOINT, args.bp_id)
		end,
		read = function(data)
			local uid
			uid, data = remedybg.io.pop_uint32(data)
			local enabled
			enabled, data = remedybg.io.pop_bool(data)
			local module_name
			module_name, data = remedybg.io.pop_string(data)
			local condition_expr
			condition_expr, data = remedybg.io.pop_string(data)
			local kind
			kind, data = remedybg.io.pop_byte(data)
			local info = {}
			if kind == RDBG_BREAKPOINT_KIND.RDBG_BREAKPOINT_KIND_FUNCTION_NAME then
				local function_name
				function_name, data = remedybg.io.pop_string(data)
				local overload_id
				overload_id, data = remedybg.io.pop_uint32(data)
				info.function_name = function_name
				info.overload_id = overload_id
			elseif kind == RDBG_BREAKPOINT_KIND.RDBG_BREAKPOINT_KIND_FILENAME_LINE then
				local filename
				filename, data = remedybg.io.pop_string(data)
				local line_num
				line_num, data = remedybg.io.pop_uint32(data)
				info.filename = filename
				info.line_num = line_num
			elseif kind == RDBG_BREAKPOINT_KIND.RDBG_BREAKPOINT_KIND_ADDRESS then
				local address
				address, data = remedybg.io.pop_uint32(data)
				info.address = address
			elseif kind == RDBG_BREAKPOINT_KIND.RDBG_BREAKPOINT_KIND_PROCESSOR then
				local addr_expression
				addr_expression, data = remedybg.io.pop_string(data)
				local num_bytes
				num_bytes, data = remedybg.io.pop_byte(data)
				local access_kind
				access_kind, data = remedybg.io.pop_byte(data)
				info.addr_expression = addr_expression
				info.num_bytes = num_bytes
				info.access_kind = access_kind
			end

			return {
				uid = uid,
				enabled = enabled,
				module_name = module_name,
				condition_expr = condition_expr,
				kind = kind,
				info = info,
			}
		end,
	},
	--
	-- Watch Window Expressions

	-- Return a list of watch expressions for the given, one-based watch window,
	-- presently ranging in [1,8].
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [window_num :: uint8_t]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [num_watches :: uint16_t]
	-- .FOR(num_watches) {
	--   [uid :: rdbg_Id]
	--   [expr :: rdbg_String]
	--   [comment :: rdbg_String]
	-- }
	[RDBG_COMMANDS.GET_WATCHES] = nil,

	-- Add a watch expresion to the given, one-based watch window. Presently,
	-- only single line comments are supported. Spaces will replace any newlines
	-- found in a comment.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [window_num :: uint8_t]
	-- [expr :: rdbg_String]
	-- [comment :: rdbg_String]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [uid :: rdbg_Id]
	[RDBG_COMMANDS.ADD_WATCH] = nil,

	-- Updates the expression for a given watch
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [uid :: rdbg_Id]
	-- [expr :: rdbg_String]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.UPDATE_WATCH_EXPRESSION] = nil,

	-- Updates the comment for a given watch
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [uid :: rdbg_Id]
	-- [comment :: rdbg_String]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.UPDATE_WATCH_COMMENT] = nil,

	-- Delete the given watch
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [uid :: rdbg_Id]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.DELETE_WATCH] = nil,

	-- Delete all watches in the given watch window
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [window_num :: uint8_t]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	[RDBG_COMMANDS.DELETE_ALL_WATCHES] = nil,
}
