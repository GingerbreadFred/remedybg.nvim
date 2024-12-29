--- @enum RDBG_COMMANDS
RDBG_COMMANDS = {
	-- Bring the RemedyBG window to the foreground and activate it. No additional
	-- arguments follow the command. Returns RESULT_OK or
	-- RESULT_FAIL.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	BRING_DEBUGGER_TO_FOREGROUND = 50,

	-- Set the size and position of the RemedyBG window.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [x :: int32_t]
	-- [y :: int32_t]
	-- [width :: int32_t]
	-- [height :: int32_t]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	SET_WINDOW_POS = 51,

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
	GET_WINDOW_POS = 52,

	-- Set whether to automatically bring the debugger to the foreground whenever
	-- the target is suspended (breakpoint hit, exception, single-step complete,
	-- etc.). Defaults to true if not set.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [bring_to_foreground_on_suspended :: rdbg_Bool (uint8_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	SET_BRING_TO_FOREGROUND_ON_SUSPENDED = 53,

	-- Exit the RemedyBG application.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [dtb :: rdbg_DebuggingTargetBehavior (uint8_t)]
	-- [msb :: rdbg_ModifiedSessionBehavior (uint8_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	EXIT_DEBUGGER = 75,

	-- Session
	--

	-- Returns whether the current session is modified, dirt =y
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [modified :: rdbg_Bool (uint8_t)]
	GET_IS_SESSION_MODIFIED = 100,

	-- Returns the current session's filename. If the filename has not been set
	-- for the session then the result will be
	-- RESULT_UNNAMED_SESSION and the length of |filename| will be
	-- zero.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [filename :: rdbg_String]
	GET_SESSION_FILENAME = 101,

	-- Creates a new session. All configurations are cleared and reset.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [dtb :: rdbg_DebuggingTargetBehavior (uint8_t)]
	-- [msb :: rdbg_ModifiedSessionBehavior (uint8_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	NEW_SESSION = 102,

	-- Open a session with the given filename.
	--
	-- [command :: rdbg_Command (uint16_t)]
	-- [dtb :: rdbg_DebuggingTargetBehavior (uint8_t)]
	-- [msb :: rdbg_ModifiedSessionBehavior (uint8_t)]
	-- [filename :: rdbg_String]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	OPEN_SESSION = 103,

	-- Save session with its current filename. If the filename is has not been
	-- specified for the session the user will be prompted. To save with a
	-- filename see SAVE_AS_SESSION, instead.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	SAVE_SESSION = 104,

	-- Save session with a given filename.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [filename :: rdbg_String]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	SAVE_AS_SESSION = 105,

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
	GET_SESSION_CONFIGS = 106,

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
	ADD_SESSION_CONFIG = 107,

	-- Sets the active configuration for a session by configuration ID. If the
	-- ID is not valid for the current session
	-- RESULT_INVALID_ID is returned.
	--
	-- [cmd :: rdbg_Command (uint16_t)
	-- [id  :: rdbg_Id]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	SET_ACTIVE_SESSION_CONFIG = 108,

	-- Deletes a session configuration by ID. If the ID is not valid for the
	-- current session REMOVE_SESSION_CONFIG is returned.
	--
	-- [cmd :: rdbg_Command (uint16_t)
	-- [id  :: rdbg_Id]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	DELETE_SESSION_CONFIG = 109,

	-- Deletes all session configurations in the current session.
	--
	-- [cmd :: rdbg_Command (uint16_t)
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	DELETE_ALL_SESSION_CONFIGS = 110,

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
	GOTO_FILE_AT_LINE = 200,

	-- Close the file with the given ID.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [id :: rdbg_Id]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	CLOSE_FILE = 201,

	-- Close all open files
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	CLOSE_ALL_FILES = 202,

	-- Returns the current file. If no file is open, returns a zero ID,
	-- zero-length filename, and zero line number.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [id :: rdbg_Id]
	-- [filename :: rdbg_String]
	-- [line_num :: uint32_t]
	GET_CURRENT_FILE = 203,

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
	GET_OPEN_FILES = 204,

	--
	-- Debugger Control

	-- Returns the target state for the current session.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [staste :: rdbg_TargetState (uint16_t)]
	GET_TARGET_STATE = 300,

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
	START_DEBUGGING = 301,

	-- Stop debugging the target. If the target is not executing this will return
	-- RESULT_INVALID_TARGET_STATE.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	STOP_DEBUGGING = 302,

	-- Restart debugging if the target is being debugging (either suspended or
	-- executing) and the target was not attached to a process. Otherwise,
	-- returns RESULT_INVALID_TARGET_STATE.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	RESTART_DEBUGGING = 303,

	-- Attach to a process by the given process-id. The value of
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
	ATTACH_TO_PROCESS_BY_PID = 304,

	-- Attach to a process by the given name. The first process found, in the
	-- case there are more than one with the same name, is used. The value of
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
	ATTACH_TO_PROCESS_BY_NAME = 305,

	-- Detach from a target that is being debugged. Can return
	-- RESULT_OK or RDBG_COMMAND_RESULT_INVALID_TARGET_STATE.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	DETACH_FROM_PROCESS = 306,

	-- With the target suspended, step into by line. If a function call occurs,
	-- this command will enter the function.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	STEP_INTO_BY_LINE = 307,

	-- With the target suspended, step into by instruction. If a function call
	-- occurs, this command will enter the function. Can return
	-- RESULT_OK or RDBG_COMMAND_RESULT_INVALID_TARGET_STATE.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	STEP_INTO_BY_INSTRUCTION = 308,

	-- With the target suspended, step into by line. If a function call occurs,
	-- this command step over that function and not enter it. Can return
	-- return RESULT_OK or RDBG_COMMAND_RESULT_INVALID_TARGET_STATE.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	STEP_OVER_BY_LINE = 309,

	-- With the target suspended, step into by instruction. If a function call
	-- occurs, this command will step over that function and not enter it. Can
	-- return RESULT_OK or RDBG_COMMAND_RESULT_INVALID_TARGET_STATE.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	STEP_OVER_BY_INSTRUCTION = 310,

	-- With the target suspended, continue running to the call site of the
	-- current function, i.e., step out.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	STEP_OUT = 311,

	-- With the target suspended, continue execution. Can return
	-- RESULT_OK or RDBG_COMMAND_RESULT_INVALID_TARGET_STATE.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	CONTINUE_EXECUTION = 312,

	-- When the target is not being debugged or is suspended, run to the given
	-- filename and line number.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [filename :: rdbg_String]
	-- [line_num :: uint32_t]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	RUN_TO_FILE_AT_LINE = 313,

	-- Halt the execution of a target that is in the executing state. Can return
	-- RESULT_OK or RDBG_COMMAND_RESULT_INVALID_TARGET_STATE.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	BREAK_EXECUTION = 314,

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
	GET_BREAKPOINTS = 600,

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
	GET_BREAKPOINT_LOCATIONS = 601,

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
	GET_FUNCTION_OVERLOADS = 602,

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
	ADD_BREAKPOINT_AT_FUNCTION = 603,

	-- Request a breakpoint at the given source file and line number.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [filename :: rdbg_String]
	-- [line_num :: uint32_t]
	-- [condition_expr :: rdbg_String]
	-- ->

	-- [bp_id :: rdbg_Id]
	ADD_BREAKPOINT_AT_FILENAME_LINE = 604,

	-- Request a breakpoint at the given address.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [address :: uint64_t]
	-- [condition_expr :: rdbg_String]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	-- [bp_id :: rdbg_Id]
	ADD_BREAKPOINT_AT_ADDRESS = 605,

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
	ADD_PROCESSOR_BREAKPOINT = 606,

	-- Sets the conditional expression for the given breakpoint. Can pass in a
	-- zero-length string for none.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [bp_id :: rdbg_Id]
	-- [condition_expr :: rdbg_String]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	SET_BREAKPOINT_CONDITION = 607,

	-- Given an existing breakpoint of type RDBG_BREAKPOINT_KIND_FILENAME_LINE,
	-- update its line number to the given one-based value.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [bp_id :: rdbg_Id]
	-- [line_num :: uint32_t]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	UPDATE_BREAKPOINT_LINE = 608,

	-- Enable or disable an existing breakpoint.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [bp_id :: rdbg_Id]
	-- [enable :: rdbg_Bool]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	ENABLE_BREAKPOINT = 609,

	-- Delete an existing breakpoint.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [bp_id :: rdbg_Id]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	DELETE_BREAKPOINT = 610,

	-- Delete all existing breakpoints.
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	DELETE_ALL_BREAKPOINTS = 611,

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
	GET_BREAKPOINT = 612,

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
	GET_WATCHES = 700,

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
	ADD_WATCH = 701,

	-- Updates the expression for a given watch
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [uid :: rdbg_Id]
	-- [expr :: rdbg_String]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	UPDATE_WATCH_EXPRESSION = 702,

	-- Updates the comment for a given watch
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [uid :: rdbg_Id]
	-- [comment :: rdbg_String]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	UPDATE_WATCH_COMMENT = 703,

	-- Delete the given watch
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [uid :: rdbg_Id]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	DELETE_WATCH = 704,

	-- Delete all watches in the given watch window
	--
	-- [cmd :: rdbg_Command (uint16_t)]
	-- [window_num :: uint8_t]
	-- ->
	-- [result :: rdbg_CommandResult (uint16_t)]
	DELETE_ALL_WATCHES = 705,
}
