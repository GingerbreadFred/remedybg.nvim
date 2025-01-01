local M = {}

local function get_buffer_for_filename(filename)
	local all_buffers = vim.api.nvim_list_bufs()
	for _, v in pairs(all_buffers) do
		if vim.api.nvim_buf_get_name(v) == filename then
			return v
		end
	end
	return nil
end
M.get_buffer_for_filename = get_buffer_for_filename

return M
