-- Minimal unmatched-bracket highlighting (no plugins, no text changes)
-- Uses: matchparen + a regex match per line
--
--   require("bracket_highlight").setup()

local M = {}

function M.setup()
	-- Enable built-in matchparen
	vim.cmd("runtime plugin/matchparen.vim")
	vim.opt.showmatch = true

	-- Highlight group for unmatched brackets (adjust as needed)
	vim.api.nvim_set_hl(0, "UnmatchedBracket", {
		fg = "#ff4444",
		bold = true,
	})

	-- Per-line scan for unmatched brackets (simple, fast, no regex pitfalls).
	local ns = vim.api.nvim_create_namespace("unmatched_bracket")
	local open_for = { [")"] = "(", ["]"] = "[", ["}"] = "{" }

	local function highlight_buffer(bufnr)
		if not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end

		vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

		for lnum, line in ipairs(lines) do
			local stack = {}
			for i = 1, #line do
				local ch = line:sub(i, i)
				if ch == "(" or ch == "[" or ch == "{" then
					table.insert(stack, { ch = ch, col = i - 1 })
				elseif ch == ")" or ch == "]" or ch == "}" then
					if #stack > 0 and stack[#stack].ch == open_for[ch] then
						table.remove(stack)
					else
						vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, i - 1, {
							end_col = i,
							hl_group = "UnmatchedBracket",
						})
					end
				end
			end

			for _, item in ipairs(stack) do
				vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, item.col, {
					end_col = item.col + 1,
					hl_group = "UnmatchedBracket",
				})
			end
		end
	end

	local group = vim.api.nvim_create_augroup("UnmatchedBracketHighlight", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI", "InsertLeave" }, {
		group = group,
		callback = function(args)
			highlight_buffer(args.buf)
		end,
	})
end

return M
