local struct = require("struct")

local M = {}

local function pop_uint16(data)
	local val, pos = struct.unpack("H", data, 1)
	return val[1], string.sub(data, pos, string.len(data))
end
M.pop_uint16 = pop_uint16

local function pop_string(data)
	local len
	len, data = pop_uint16(data)
	if len == 0 then
		return "", data
	end

	local str, new_pos = struct.unpack("c" .. len, data, 1)

	return str[1], string.sub(data, new_pos, string.len(data))
end
M.pop_string = pop_string

local function pop_uint32(data)
	local val, pos = struct.unpack("I", data, 1)
	return val[1], string.sub(data, pos, string.len(data))
end
M.pop_uint32 = pop_uint32

local function pop_bool(data)
	local val, pos = struct.unpack("B", data, 1)
	return val[1] and true, string.sub(data, pos, string.len(data))
end
M.pop_bool = pop_bool

local function pop_byte(data)
	local val, pos = struct.unpack("B", data, 1)
	return val[1], string.sub(data, pos, string.len(data))
end
M.pop_byte = pop_byte
return M
