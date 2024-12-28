RDBG_DEBUG_EVENTS = {
	-- A target being debugged has exited.
	EXIT_PROCESS = 100,
	-- The target for the active configuration is now being debugged.
	TARGET_STARTED = 101,
	-- The debugger has attached to a target process.
	TARGET_ATTACHED = 102,
	-- The debugger has detached from a target process.
	TARGET_DETACHED = 103,
	-- The debugger has transitioned from suspended to executing.
	TARGET_CONTINUED = 104,
	-- The source location changed due to an event in the debugger.
	SOURCE_LOCATION_CHANGED = 200,
	-- A user breakpoint was hit
	BREAKPOINT_HIT = 600,
	-- The breakpoint with the given ID has been resolved (has a valid location).
	-- This can happen if the breakpoint was set in module that became loaded,
	-- for instance.
	BREAKPOINT_RESOLVED = 601,
	-- A new user breakpoint was added.
	BREAKPOINT_ADDED = 602,
	-- A user breakpoint was modified.
	BREAKPOINT_MODIFIED = 603,
	-- A user breakpoint was removed.
	BREAKPOINT_REMOVED = 604,
	-- An OutputDebugString was received by the debugger. The given string will
	-- be UTF-8 encoded.
	OUTPUT_DEBUG_STRING = 800,
}
