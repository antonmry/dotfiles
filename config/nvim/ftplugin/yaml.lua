-- brew install yamllint yamlfmt

-- Formatter
require("conform").formatters_by_ft.yaml = { "yamlfmt" }

-- Linter
require("lint").linters_by_ft.yaml = { "yamllint" }
