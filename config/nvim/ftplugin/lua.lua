-- brew install stylua

-- Formatter
require("conform").formatters_by_ft.lua = { "stylua" }

-- Linter
-- require("lint").linters_by_ft.lua = { "luac" }

-- LSP
-- Delete this in favor of .luarc.json?
vim.lsp.start({
	name = "lua_ls",
	cmd = { "lua-language-server" },
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
		},
	},
})
