-- brew install rust-analyzer

-- Formatter
require("conform").formatters_by_ft.rust = { "rustfmt" }

-- Linter
require("lint").linters_by_ft.rust = { "clippy" }

-- LSP

vim.lsp.start({
	name = "rust-analyzer",
	cmd = { "rust-analyzer" },
	root_dir = vim.fs.dirname(vim.fs.find({ "Cargo.toml", "main.rs" }, { upward = true })[1]),
})
