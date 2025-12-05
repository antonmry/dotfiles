local M = {}

local function refresh(bufnr)
	local ok_data, data = pcall(require, "aerial.data")
	local ok_aerial, aerial = pcall(require, "aerial")
	if not ok_data or not ok_aerial then
		return
	end

	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	local has_symbols = data.has_symbols(bufnr)
	if has_symbols then
		pcall(aerial.open, { focus = false })
	else
		pcall(aerial.close)
	end
end

function M.refresh(bufnr)
	refresh(bufnr)
end

function M.setup()
	local group = vim.api.nvim_create_augroup("AerialAutoToggle", { clear = true })

	-- Only act when a buffer is read the first time, not on subsequent writes/enters.
	vim.api.nvim_create_autocmd({ "BufReadPost" }, {
		group = group,
		callback = function(args)
			vim.defer_fn(function()
				refresh(args.buf)
			end, 100)
		end,
	})

end

return M
