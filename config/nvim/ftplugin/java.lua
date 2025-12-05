-- brew install google-java-format jdtls

-- Formatter
require("conform").formatters_by_ft.java = { "google-java-format" }

-- Linter: TODO checkstype? Spotbugs?
--require("lint").linters_by_ft.java = { "" }

-- LSP
-- https://github.com/eclipse-jdtls/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line
-- See for more options/ideas: https://www.reddit.com/r/neovim/comments/11k3zuv/jdtls_and_lazyvim/

vim.lsp.start({
	name = "jdtls",
	cmd = { "jdtls" },
	root_dir = vim.fs.dirname(vim.fs.find({ "build.gradle", "pom.xml" }, { upward = true })[1]),
})
