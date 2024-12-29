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
}

--- @param file string
--- @param line integer
function breakpoint:new(file, line)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	self.file = file
	self.line = line
	self.active = true

	local all_buffers = vim.api.nvim_list_bufs()

	for _, v in pairs(all_buffers) do
		if vim.api.nvim_buf_get_name(v) == file then
			self.sign_id = vim.fn.sign_place(0, "breakpoint", "breakpoint", v, { lnum = line })
		end
	end

	return o
end

function breakpoint:remove()
	if self.sign_id then
		vim.fn.sign_unplace("breakpoint", { id = self.sign_id })
	end
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

	table.insert(self.active_breakpoints, breakpoint:new(file, line))
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

return breakpoints
