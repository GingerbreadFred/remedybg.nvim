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
	--- @type integer?
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
			o:create_sign(v)
		end
	end

	return o
end

function breakpoint:create_sign(buffer)
	self:remove()
	self.sign_id = vim.fn.sign_place(0, "breakpoint", "breakpoint", buffer, { lnum = self.line })
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
			for _, callbacks in pairs(self.breakpoint_removed) do
				callbacks(v)
			end
			table.remove(self.active_breakpoints, k)
			return
		end
	end

	local new_breakpoint = breakpoint:new(file, line)
	table.insert(self.active_breakpoints, new_breakpoint)
	for _, callbacks in pairs(self.breakpoint_added) do
		callbacks(new_breakpoint)
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

---Triggered when a breakpoint is removed by remedybg
---@param bp_id integer
function breakpoints:on_breakpoint_removed_remotely(bp_id)
	-- First search for breakpoints we already know about and update if found
	for k, v in pairs(self.active_breakpoints) do
		if v.remedybg_id == bp_id then
			v:remove()
			table.remove(self.active_breakpoints, k)
			return
		end
	end
end

function breakpoints:on_debugger_terminated()
	for _, v in pairs(self.active_breakpoints) do
		v:set_remedybg_id(nil)
	end
end

function breakpoints:populate_signs(buffer)
	local filename = vim.api.nvim_buf_get_name(buffer)
	for _, v in pairs(self.active_breakpoints) do
		if v.file == filename then
			v:create_sign(buffer)
		end
	end
end

return breakpoints
