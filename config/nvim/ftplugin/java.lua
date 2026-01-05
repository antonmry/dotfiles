-- brew install google-java-format jdtls

-- Formatter
require("conform").formatters_by_ft.java = { "google-java-format" }

-- Linter: TODO checkstype? Spotbugs?
--require("lint").linters_by_ft.java = { "" }

-- LSP
-- https://github.com/eclipse-jdtls/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line
-- See for more options/ideas: https://www.reddit.com/r/neovim/comments/11k3zuv/jdtls_and_lazyvim/

local function find_root(markers)
	local found = vim.fs.find(markers, { upward = true })[1]
	if found then
		return vim.fs.dirname(found)
	end
	local fname = vim.api.nvim_buf_get_name(0)
	if fname ~= "" then
		return vim.fs.dirname(fname)
	end
	return vim.fn.getcwd()
end

vim.lsp.start({
	name = "jdtls",
	cmd = { "jdtls" },
	root_dir = find_root({ "build.gradle", "pom.xml" }),
})
