local remedybg = {
	session = require("remedybg.session"),
	breakpoints = require("remedybg.breakpoints"),
}

local M = {}
--- @class opts
local opts = {
	get_debugger_targets = nil,
}

--- @type session
local active_session = nil
--- @type breakpoints
local breakpoints = remedybg.breakpoints:new()

function M.setup(in_opts)
	--- TODO: Better option handling
	opts = in_opts or opts
	remedybg.breakpoints.setup()
	remedybg.session.setup()
end

--- @param executable_command string
function M.setup_debugger(executable_command)
	active_session = remedybg.session:new(executable_command, breakpoints)
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

function M.continue_execution()
	if not active_session then
		if opts.get_debugger_targets and opts.get_debugger_targets() then
			opts.get_debugger_targets()(function(cmd)
				M.setup_debugger(cmd)
			end)
		else
			local prompt = "Target: "
			local target = vim.fn.input(prompt)
			M.setup_debugger(target)
		end
	else
		active_session:continue_execution()
	end
end

function M.populate_signs(buffer)
	breakpoints:on_buffer_loaded(buffer)
	if active_session then
		active_session:on_buffer_loaded(buffer)
	end
end

return M
