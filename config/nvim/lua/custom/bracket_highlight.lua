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

	-- Pattern that finds bracket characters that *cannot* be matched on the line.
	--
	-- This is intentionally simple: unmatched “( [ { ) ] }” per line.
	--
	-- Limitations:
	--   - Detects unmatched brackets per line (not per file)
	--   - Good enough for catching mistakes visually without plugins
	--
	local pattern = [[\V\%(\%([^()]*\)\@<![(]\|\%([^()]*\)\@<![)]\)]]

	vim.fn.matchadd("UnmatchedBracket", pattern, 10)
end

return M
