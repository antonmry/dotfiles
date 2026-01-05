-- brew install 

-- Formatter
require("conform").formatters_by_ft.python = { "ruff_fix", "ruff_format", "ruff_organize_imports" }

-- Linter
-- require("lint").linters_by_ft.python = { "ruff" }

if vim.lsp.config and vim.lsp.config.ty then
	vim.lsp.enable("ty")
end
