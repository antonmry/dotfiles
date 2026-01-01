-- Formatter
require("conform").formatters_by_ft.rust = { "rustfmt" }

-- Linter (using LSP clippy instead)
-- require("lint").linters_by_ft.rust = { "clippy" }

-- Folding via LSP (rust-analyzer)
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"

-- LSP
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities.textDocument.selectionRange = { dynamicRegistration = false }

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
		if vim.lsp.inlay_hint then
			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		end

		vim.g.rustfmt_autosave = 1
	end,
})

vim.lsp.start({
	name = "rust-analyzer",
	cmd = { "rust-analyzer" },
	root_dir = vim.fs.dirname(vim.fs.find({ "Cargo.toml", "main.rs" }, { upward = true })[1]),
	-- capabilities = capabilities,
	settings = {
		["rust-analyzer"] = {
			check = {
				command = "clippy",
			},
			completion = {
				callable = {
					snippets = "fill_arguments",
				},
				snippets = {
					custom = {
						test_fn = {
							prefix = "test",
							body = [[
#[test]
fn ${1:name}() {
    ${0}
}
]],
							description = "Test function",
							scope = "item",
						},
						test_mod = {
							prefix = "testmod",
							body = [[
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ${1:name}() {
        ${0}
    }
}
]],
							description = "Test module with one test",
							scope = "item",
						},
					},
				},
			},
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

-- Compile
function CompileSomeRust()
	print("cargo check...")
	vim.cmd("silent make! check")
	vim.cmd("redraw!")
	local qf_list = vim.fn.getqflist()
	local error_count = 0
	local warning_count = 0
	if #qf_list > 0 then
		local collect_err = false
		for _, i in pairs(qf_list) do
			if i.type == "W" then
				warning_count = warning_count + 1
				collect_err = false
			end
			if i.type == "E" then
				collect_err = true
				error_count = error_count + 1
			end
			if collect_err then
				table.insert(qf_list, i)
			end
		end
	end

	if error_count > 0 then
		if vim.fn.tabpagewinnr(vim.fn.tabpagenr(), "$") > 1 then
			vim.cmd("botright copen 6")
		else
			vim.cmd("copen 6")
		end
		vim.cmd("wincmd p")
		vim.cmd("cfirst")
	else
		vim.cmd("cclose")
	end

	local err_out = "echo 'E: " .. error_count .. "'"
	local warn_out = " | echon ' | W: " .. warning_count .. "'"
	vim.cmd(err_out .. warn_out)
end

local opts = { noremap = true, silent = true }
vim.api.nvim_create_user_command("Compile", CompileSomeRust, {})
vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>c", "<cmd>:wa<CR>:Compile<CR>", opts)
vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>r", "<cmd>:wa<CR>:Cargo run<CR>", opts)
vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>t", "<cmd>:wa<CR>:Cargo test<CR>", opts)
