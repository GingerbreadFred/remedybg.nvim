local plugin = require("remedybg")

vim.api.nvim_create_autocmd({ "BufRead" }, {
	callback = function(ev)
		plugin.populate_signs(ev.buf)
	end,
})
