local remedybg = {
	session = require("remedybg.session"),
	breakpoints = require("remedybg.breakpoints"),
}

local M = {}

--- @type session
local active_session = nil
--- @type breakpoints
local breakpoints = remedybg.breakpoints:new()

function M.setup()
	breakpoints.setup()
end

--- @param executable_command string
function M.setup_debugger(executable_command)
	active_session = remedybg.session:new(executable_command, breakpoints)
end

---@param break_at_entry_point boolean
function M.start_debugging(break_at_entry_point)
	active_session:start_debugging(break_at_entry_point)
end

function M.step_into()
	active_session:step_into()
end

function M.step_over()
	active_session:step_over()
end

function M.step_out()
	active_session:step_out()
end

function M.toggle_breakpoint()
	local current_buffer = vim.api.nvim_get_current_buf()
	breakpoints:toggle_breakpoint(
		vim.api.nvim_buf_get_name(current_buffer),
		vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[1]
	)
end

return M
