-- brew install sqlfluff

-- Formatter

local conform = require("conform")

-- Custom for duckdb
conform.formatters.duckdb = {
	command = "sqlfluff",
	args = {
		"fix",
		"--dialect",
		"duckdb",
		"--disable-progress-bar",
		"-n",
		"-",
	},
	stdin = true,
}

conform.formatters_by_ft.sql = { "duckdb" }

-- Linter

-- local lint = require("lint")
--
-- local sqlfluff = lint.linters.sqlfluff
--
-- sqlfluff.args = {
-- 	"lint",
-- 	"--format=json",
-- 	"--dialect=duckdb",
-- }
--
-- lint.linters_by_ft = {
-- 	sql = { "sqlfluff" },
-- }
