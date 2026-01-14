-- brew install ty

-- Formatter
require("conform").formatters_by_ft.python = { "ruff_fix", "ruff_format", "ruff_organize_imports" }

-- Linter
-- require("lint").linters_by_ft.python = { "ruff" }

local bufnr = vim.api.nvim_get_current_buf()
local root = vim.fs.root(bufnr, { "ty.toml", "pyproject.toml", "setup.py", "requirements.txt" })

vim.lsp.start({
	name = "ty",
	cmd = { "ty", "server" },
	root_dir = root or vim.fn.getcwd(),
})
