local remedybg = {
	session = require("remedybg.session"),
}

local M = {}

--- @type session
local active_session = nil

function M.Setup() end

--- @param executable_command string
function M.SetupDebugger(executable_command)
	active_session = remedybg.session:new(executable_command)
end

function M.StartDebugging(break_at_entry_point)
	active_session:start_debugging(break_at_entry_point)
end

function M.StepInto()
	active_session:step_into()
end

function M.StepOver()
	active_session:step_over()
end

return M
