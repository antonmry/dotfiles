-- brew install jq cspell

-- Formatter
require("conform").formatters_by_ft.jsonl = { "jq" }

-- Linter
-- require("lint").linters_by_ft.jsonl = { "cspell" }
