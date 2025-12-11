local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

----------------
--- plugins ---
----------------
require("lazy").setup({
	dev = {
		path = "~/Workspace/Others/nvim_plugins",
		patterns = { "antonmry" },
		fallback = false,
	},

	spec = {

		-- Default linter
		{
			"mfussenegger/nvim-lint",
		},

		-- Default formatter
		{
			"stevearc/conform.nvim",
			config = function()
				require("conform").setup({
					log_level = vim.log.levels.WARN,
					notify_on_error = true,
					notify_no_formatters = true,
				})
			end,
		},
		-- Fuzzy finder (instead of telescope)
		{
			"ibhagwan/fzf-lua",
			-- optional for icon support
			dependencies = { "nvim-tree/nvim-web-devicons" },
			config = function()
				-- calling `setup` is optional for customization
				require("fzf-lua").setup({})
				require("fzf-lua").register_ui_select()
			end,
		},
		{
			"stevearc/aerial.nvim",
			opts = {},
			-- Optional dependencies
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
				"nvim-tree/nvim-web-devicons",
			},
		},
	},
})

----------------
--- SETTINGS ---
----------------

vim.opt.background = "light"
vim.opt.termguicolors = true -- Enable 24-bit RGB colors
vim.cmd.colorscheme("minimum")
vim.opt.colorcolumn = "81" -- sets the columns at which to display a color marker.

vim.opt.number = true -- Show line numbers
vim.opt.showmatch = true -- Highlight matching parenthesis
vim.opt.splitright = true -- Split windows right to the current windows
vim.opt.splitbelow = true -- Split windows below to the current windows
vim.opt.autowrite = true -- Automatically save before :next, :make etc.

vim.opt.swapfile = false -- Don't use swapfile
vim.opt.ignorecase = true -- Search case insensitive...
vim.opt.smartcase = true -- ... but not it begins with upper case
-- Don't use preview here: https://vi.stackexchange.com/questions/39972/prevent-neovim-lsp-from-opening-a-scratch-preview-buffer
vim.opt.completeopt = "menuone,noinsert,popup" -- Autocomplete options
vim.opt.wildmode = "list,full" --  First tab: list, second tab: complete
vim.opt.wildoptions = "fuzzy" -- Command-line completion mode

vim.opt.showbreak = "↪" -- sets the string to be shown in front of lines that are wrapped
vim.opt.listchars = "tab:→\\ ,nbsp:␣,trail:•,extends:⟩,precedes:⟨" -- sets the characters for displaying tabs and trailing spaces.
vim.opt.list = true -- enables the display of the `listchars`.

vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "undo"

-- Disable status bar
vim.opt.ruler = false
vim.opt.laststatus = 0
vim.opt.showcmd = false
vim.opt.cmdheight = 1

-- Indent Settings
vim.opt.autoindent = true -- copy indent from current line when starting a new line
vim.opt.wrap = true
vim.opt.tabstop = 8
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Spell checking
vim.opt.spelllang = "en_us"
vim.opt.spell = true

--------------------
--- DIAGNOSTIC -----
--------------------

-- the following show handler will show the most recent diagnostics
-- https://neovim.io/doc/user/diagnostic.html#diagnostic-loclist-example
vim.diagnostic.handlers.loclist = {
	---@param opts? {loclist?: {open?: boolean}}
	show = function(_, _, _, opts)
		-- Generally don't want it to open on every update
		local loclist_opts = (opts and opts.loclist) or {}
		loclist_opts.open = loclist_opts.open or false
		local winid = vim.api.nvim_get_current_win()
		vim.diagnostic.setloclist(loclist_opts)
		vim.api.nvim_set_current_win(winid)
	end,
}

-- Disable diagnostics on insert mode (hack) https://github.com/neovim/neovim/issues/13324
-- vim.api.nvim_create_autocmd({ "BufNew", "InsertEnter" }, {
-- or vim.api.nvim_create_autocmd({"BufNew", "TextChanged", "TextChangedI", "TextChangedP", "TextChangedT"}, {
-- 	callback = function(args)
-- 		vim.diagnostic.enable(false, { bufnr = args.buf })
-- 	end,
-- })

-- vim.api.nvim_create_autocmd({ "BufWrite" }, {
-- 	callback = function(args)
-- 		vim.diagnostic.enable(true, { bufnr = args.buf })
-- 	end,
-- })

vim.diagnostic.config({
	underline = false,
	signs = true,
	virtual_text = true,
	float = {
		-- 	show_header = true,
		-- 	source = "if_many",
		border = "rounded",
		-- 	focusable = false,
	},
	-- Open the location list on every diagnostic change (warnings/errors only).
	-- loclist = {
	-- 	open = true,
	-- 	severity = { min = vim.diagnostic.severity.HINT },
	-- },
})

-----------------
--- KEYMAPS -----
-----------------

-- This comes first, because we have mappings that depend on leader
vim.g.mapleader = " "

-- Exit on jj and jk
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

vim.keymap.set("n", "gl", function()
	if not vim.tbl_isempty(vim.fn.getloclist(0)) then
		vim.cmd("ll")
	else
		print("Location list is empty")
	end
end, { desc = "Move to the next one in the locationlist" })

vim.keymap.set({ "n", "v" }, "<leader>g", function()
	vim.cmd("lua require('fzf-lua').live_grep()")
end, { silent = true })
vim.keymap.set({ "n", "v" }, "<leader>n", function()
	vim.cmd("lua require('fzf-lua').files()")
end, { silent = true })
vim.keymap.set({ "n", "v" }, "<leader>h", function()
	vim.cmd("lua require('fzf-lua').command_history()")
end, { silent = true })
vim.keymap.set("n", "<leader>:", function()
	vim.cmd("lua require('fzf-lua').commands()")
end, { silent = true })

-- See the doc for the global defaults: https://neovim.io/doc/user/lsp.html
vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	---@param event {buf: integer, data: {client_id: integer}}
	callback = function(event)
		---@type vim.lsp.Client?
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		local opts = { buffer = event.buf }

		-- Enable built-in LSP completion
		if
			client
			and client.supports_method("textDocument/completion")
			and vim.lsp.completion
			and vim.lsp.completion.enable
		then
			-- enable completion provider for this client/buffer
			vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
		else
			vim.bo[event.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
		end

		-- Completion accept on <CR> (menu confirm)
		vim.keymap.set("i", "<CR>", function()
			if vim.fn.pumvisible() == 1 then
				return "<C-y>"
			end
			return "<CR>"
		end, { buffer = event.buf, expr = true, silent = true })

		vim.keymap.set("n", "grd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
		vim.keymap.set("n", "grD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
		vim.keymap.set("n", "grs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
		vim.keymap.set({ "n", "x" }, "grf", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
	end,
})

vim.keymap.set("", "<leader>f", function()
	require("conform").format({ async = true }, function(err)
		if not err then
			local mode = vim.api.nvim_get_mode().mode
			if vim.startswith(string.lower(mode), "v") then
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
			end
		end
	end)
end, { desc = "Format code" })

vim.keymap.set("n", "<leader>l", function()
	require("lint").try_lint()
end, { desc = "Trigger linting for current file" })

-----------------
--- EXPLORER ----
-----------------

vim.g.netrw_banner = 0 -- no banner
vim.g.netrw_liststyle = 3 -- tree view
vim.g.netrw_browse_split = 0 -- open files in the current window
vim.g.netrw_winsize = 25 -- if you ever use splits
vim.g.netrw_altv = 1 -- split to the right, if split
vim.g.netrw_keepdir = 1 -- keep current working directory unchanged

-- Hide some junk files by default (adjust to taste)
vim.g.netrw_list_hide = [[^\.\.\=/\=$]]
	.. [[,\(^\|\s\s\)\zs\.\S\+]] -- dotfiles (toggle with 'gh')
	.. [[,\~$]]
	.. [[,\.swp$]]
	.. [[,\.git$]]

-- 3. Keymap: "-" opens a "directory buffer" like oil.nvim,
--    rooted at the current file's directory (or CWD if no file).
vim.keymap.set("n", "-", function()
	local path = vim.fn.expand("%:p")
	if path == "" then
		-- no buffer filename -> use current working directory
		vim.cmd("Explore")
	else
		vim.cmd("Explore " .. vim.fn.fnameescape(vim.fn.expand("%:p:h")))
	end
end, { desc = "Open netrw in current directory" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "netrw",
	callback = function(args)
		local opts = { buffer = args.buf, noremap = true, silent = true }
		vim.keymap.set("n", "?", ":help netrw-quickhelp<CR>", opts)
	end,
})

-----------------
----- AERIAL ----
-----------------

require("aerial").setup({
	-- optionally use on_attach to set keymaps when aerial has attached to a buffer
	on_attach = function(bufnr)
		-- Jump forwards/backwards with '{' and '}'
		vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
		vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
	end,
})

vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")

---------------------
----- TREESEETER ----
---------------------

-- vim.api.nvim_create_autocmd("FileType", {
--     callback = function(ev)
--         pcall(vim.treesitter.start, ev.buf)
--     end
-- })

vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

local has_ts, ts_configs = pcall(require, "nvim-treesitter.configs")
if has_ts then
	ts_configs.setup({
		modules = {},
		sync_install = true,
		auto_install = true,
		ignore_install = {},
		ensure_installed = {
			"lua",
			"rust",
			"markdown",
			"markdown_inline",
			"json",
			"yaml",
			"bash",
			"python",
			"javascript",
			"typescript",
		},
		highlight = {
			enable = true,
		},
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "gnn",
				node_incremental = "gni",
				scope_incremental = "gns",
				node_decremental = "gnd",
			},
		},
	})
else
	vim.notify("nvim-treesitter not available; skipping config", vim.log.levels.WARN)
end

----------------
--- CUSTOM  ----
----------------

-- Compare the current buffer with the original file
vim.cmd([[command DiffOrig vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis | wincmd p | diffthis]])

--require("custom.aerial_auto").setup()
require("custom.bracket_highlight").setup()

-- Yank helpers
local yank = require("custom.yank")
vim.api.nvim_create_user_command("YankPathAbsolute", function()
	yank.yank_path(yank.get_buffer_absolute(), "absolute")
end, { desc = "Yank absolute path to clipboard" })
vim.api.nvim_create_user_command("YankPathRelative", function()
	yank.yank_path(yank.get_buffer_cwd_relative(), "relative")
end, { desc = "Yank relative path to clipboard" })
vim.api.nvim_create_user_command("YankSelectionAbsolute", function(args)
	yank.yank_range_with_path(yank.get_buffer_absolute(), "absolute", args.line1, args.line2)
end, { range = true, desc = "Yank selection with absolute path and line range" })
vim.api.nvim_create_user_command("YankSelectionRelative", function(args)
	yank.yank_range_with_path(yank.get_buffer_cwd_relative(), "relative", args.line1, args.line2)
end, { range = true, desc = "Yank selection with relative path and line range" })
