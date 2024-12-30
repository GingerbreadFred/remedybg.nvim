--- @class breakpoint
local breakpoint = {
	--- @type boolean
	active = true,
	--- @type integer
	line = nil,
	--- @type string
	file = nil,
	--- @type integer?
	sign_id = nil,

	-- TODO: SETUP
	remedybg_id = nil,
}

--- @param file string
--- @param line integer
function breakpoint:new(file, line, remedybg_id)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.file = file
	o.line = line
	o.active = true
	o.remedybg_id = remedybg_id

	local all_buffers = vim.api.nvim_list_bufs()

	for _, v in pairs(all_buffers) do
		if vim.api.nvim_buf_get_name(v) == file then
			o.sign_id = vim.fn.sign_place(0, "breakpoint", "breakpoint", v, { lnum = line })
		end
	end

	return o
end

function breakpoint:remove()
	if self.sign_id then
		vim.fn.sign_unplace("breakpoint", { id = self.sign_id })
	end
end

function breakpoint:set_remedybg_id(bp_id)
	self.remedybg_id = bp_id
end

--- @class breakpoints
local breakpoints = {
	--- @type breakpoint[]
	active_breakpoints = {},

	--- @type fun(breakpoint : breakpoint)[]
	breakpoint_added = {},

	--- @type fun(breakpoint : breakpoint)[]
	breakpoint_removed = {},
}

function breakpoints.setup()
	vim.fn.sign_define("breakpoint", { text = "B", texthl = "", linehl = "", numhl = "" })
end

function breakpoints:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self

	return o
end

--- @param file string
--- @param line integer
function breakpoints:toggle_breakpoint(file, line)
	for k, v in pairs(self.active_breakpoints) do
		if v.file == file and v.line == line then
			v:remove()
			table.remove(self.active_breakpoints, k)
			return
		end
	end

	local new_breakpoint = breakpoint:new(file, line)
	table.insert(self.active_breakpoints, new_breakpoint)
	for _, v in pairs(self.breakpoint_added) do
		v(new_breakpoint)
	end
end

--- @param callback fun(breakpoint : breakpoint)
function breakpoints:on_breakpoint_added(callback)
	table.insert(self.breakpoint_added, callback)
end

--- @param callback fun(breakpoint : breakpoint)
function breakpoints:on_breakpoint_removed(callback)
	table.insert(self.breakpoint_removed, callback)
end

---@return breakpoint[]
function breakpoints:get_breakpoints()
	return self.active_breakpoints
end
---Triggered when a breakpoint is added by remedybg
---This may be in response to either a breakpoint we created or a breakpoint added by the user in the debugger
---@param filename string
---@param line_num integer
---@param bp_id integer
function breakpoints:on_breakpoint_added_remotely(filename, line_num, bp_id)
	-- First search for breakpoints we already know about and update if found
	for _, v in pairs(self.active_breakpoints) do
		if v.file == filename and v.line == line_num then
			v:set_remedybg_id(bp_id)
			return
		end
	end

	-- if we didn't already know about this breakpoint it must be new so create
	table.insert(self.active_breakpoints, breakpoint:new(filename, line_num, bp_id))
end

return breakpoints