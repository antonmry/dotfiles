-- brew install vale deno_fmt

-- Formatter
require("conform").formatters_by_ft.markdown = { "deno_fmt" }

-- Linter
require("lint").linters_by_ft.markdown = { "vale" }
