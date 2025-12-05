-- Formatter
require("conform").formatters_by_ft.rust = { "rustfmt" }

-- Linter
require("lint").linters_by_ft.rust = { "clippy" }

-- LSP
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.selectionRange = { dynamicRegistration = false }

local bufnr = vim.api.nvim_get_current_buf()

-- Ensure inlay hints and underlines stay visible
local function set_rust_highlights()
	local function to_color(val, fallback_cterm)
		local color = vim.api.nvim_get_color_by_name(val)
		if color == -1 then
			return fallback_cterm
		end
		return color
	end
	local function set(name, gui_hex, cterm_fallback, underline_style, italic_style)
		local fg = to_color(gui_hex, cterm_fallback)
		vim.api.nvim_set_hl(0, name, {
			fg = fg,
			ctermfg = cterm_fallback,
			undercurl = underline_style,
			underline = underline_style,
			italic = italic_style,
			nocombine = true,
			link = nil,
			sp = fg,
		})
	end

	set("LspInlayHint", "#adadad", 69, false, true)
	set("DiagnosticUnderlineError", "#db4b4b", 167, true, false)
	set("DiagnosticUnderlineWarn", "#e0af68", 214, true, false)
	set("DiagnosticUnderlineInfo", "#0db9d7", 45, true, false)
	set("DiagnosticUnderlineHint", "#10b981", 36, true, false)
end
set_rust_highlights()
local rust_hl_group = vim.api.nvim_create_augroup("RustHl" .. bufnr, { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
	group = rust_hl_group,
	callback = set_rust_highlights,
})

vim.api.nvim_create_autocmd("LspAttach", {
	buffer = bufnr,
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client or client.name ~= "rust-analyzer" then
			return
		end

		-- Ensure selectionRange is published (some builds omit it even when enabled)
		if client.server_capabilities then
			client.server_capabilities.selectionRangeProvider = client.server_capabilities.selectionRangeProvider
				or true
		end

		local namespace = vim.lsp.diagnostic.get_namespace(args.data.client_id)
		vim.diagnostic.config({
			virtual_text = false,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		}, namespace)

		if vim.lsp.inlay_hint then
			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		end
	end,
})

vim.lsp.start({
	name = "rust-analyzer",
	cmd = { "rust-analyzer" },
	root_dir = vim.fs.dirname(vim.fs.find({ "Cargo.toml", "main.rs" }, { upward = true })[1]),
	capabilities = capabilities,
	settings = {
		["rust-analyzer"] = {
			selectionRange = {
				enable = true,
			},
			inlayHints = {
				typeHints = { enable = true },
				parameterHints = { enable = true },
				lifetimeElisionHints = {
					enable = true,
					useParameterNames = true,
				},
			},
		},
	},
})
