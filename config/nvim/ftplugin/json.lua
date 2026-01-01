-- brew install jq cspell

-- Formatter
require("conform").formatters_by_ft.json = { "jq" }

-- Linter
-- require("lint").linters_by_ft.json = { "cspell" }
