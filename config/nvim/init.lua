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

		-- LSP extensions
		{
			"neovim/nvim-lspconfig",
		},

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
		-- File browser
		{
			"stevearc/oil.nvim",
		},
		{
			"michaelb/sniprun",
			branch = "master",

			build = "sh install.sh",
			config = function()
				require("sniprun").setup({
					-- your options
				})
			end,
		},
	},
})

----------------
--- SETTINGS ---
----------------

vim.opt.background = "light"
vim.opt.termguicolors = true -- Enable 24-bit RGB colors
--vim.cmd.colorscheme("minimum")
vim.cmd.colorscheme("default")
vim.cmd([[highlight Normal guibg=#ffffff]])
vim.opt.colorcolumn = "101" -- sets the columns at which to display a color marker.

vim.opt.number = true -- Show line numbers
vim.opt.showmatch = true -- Highlight matching parenthesis
vim.opt.splitright = true -- Split windows right to the current windows
vim.opt.splitbelow = true -- Split windows below to the current windows
vim.opt.autowrite = true -- Automatically save before :next, :make etc.

vim.opt.swapfile = false -- Don't use swapfile
vim.opt.ignorecase = true -- Search case insensitive...
vim.opt.smartcase = true -- ... but not it begins with upper case
-- Don't use preview here: https://vi.stackexchange.com/questions/39972/prevent-neovim-lsp-from-opening-a-scratch-preview-buffer
vim.opt.completeopt = { "noinsert", "menuone", "fuzzy" }
-- vim.opt.wildmode = "list,full" --  First tab: list, second tab: complete
-- vim.opt.wildoptions = "fuzzy" -- Command-line completion mode

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
	--update_in_insert = true,
	severity_sort = true,
	-- Open the location list on every diagnostic change (warnings/errors only).
	-- loclist = {
	-- 	open = true,
	-- 	severity = { min = vim.diagnostic.severity.HINT },
	-- },
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end

		-- Completion accept on <CR> (menu confirm)
		vim.keymap.set("i", "<CR>", function()
			if vim.fn.pumvisible() == 1 then
				return "<C-y>"
			end
			return "<CR>"
		end, { buffer = ev.buf, expr = true, silent = true })
	end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function()
		vim.diagnostic.config({ signs = false, underline = false, virtual_text = false })
	end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
	callback = function()
		vim.diagnostic.config({ signs = false, underline = true, virtual_text = false })
	end,
})
vim.api.nvim_create_autocmd("BufWritePost", {
	callback = function()
		vim.diagnostic.setloclist({ open = false })
		vim.diagnostic.config({ signs = true, underline = true, virtual_text = true })
	end,
})

-----------------
--- KEYMAPS -----
-----------------

-- This comes first, because we have mappings that depend on leader
vim.g.mapleader = " "

-- Exit on jj and jk
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

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
vim.keymap.set("n", "grd", "<cmd>lua vim.lsp.buf.definition()<cr>", {})
vim.keymap.set("n", "grD", "<cmd>lua vim.lsp.buf.declaration()<cr>", {})
vim.keymap.set("n", "grs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", {})
vim.keymap.set({ "n", "x" }, "grf", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", {})

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

vim.keymap.set("n", "-", function()
	local path = vim.fn.expand("%:p")
	if path == "" then
		-- no buffer filename -> use current working directory
		vim.cmd("Oil")
	else
		vim.cmd("Oil " .. vim.fn.fnameescape(vim.fn.expand("%:p:h")))
	end
end, { desc = "Open Oil in current directory" })

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
				node_incremental = "gnn",
				scope_incremental = false,
				node_decremental = "<bs>",
			},
		},
	})
else
	vim.notify("nvim-treesitter not available; skipping config", vim.log.levels.WARN)
end

-----------------
--- EXPLORER ----
-----------------

-- disable netrw at the very start of our init.lua, because we use Oil
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("oil").setup({
	default_file_explorer = true,
	delete_to_trash = true,
	skip_confirm_for_simple_edits = true,
	prompt_save_on_select_new_entry = true,
	-- Set to true to watch the filesystem for changes and reload oil
	watch_for_changes = false,
	view_options = {
		-- Show files and directories that start with "."
		show_hidden = true,
		-- This function defines what is considered a "hidden" file
		is_hidden_file = function(name, _)
			local m = name:match("^%.")
			return m ~= nil
		end,
		is_always_hidden = function(name, _)
			return false
		end,
	},
})

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
