-- brew install stylua

-- Formatter
require("conform").formatters_by_ft.lua = { "stylua" }

-- Linter
require("lint").linters_by_ft.lua = { "luac" }

-- LSP
vim.lsp.start({
	name = "lua_ls",
	cmd = { "lua-language-server" },
})
