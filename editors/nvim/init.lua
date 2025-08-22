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
		-- Show pairs
		{
			"windwp/nvim-autopairs",
			config = function()
				require("nvim-autopairs").setup({
					check_ts = true,
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
			end,
		},

		-- File browser
		{
			"stevearc/oil.nvim",
			opts = {},
		},

		-- Execute text in the terminal
		-- TBA

		-- Custom local plugins
		{
			"antonmry/sliwez.nvim",
			dev = true,
		},
	},
})

----------------
--- SETTINGS ---
----------------

-- disable netrw at the very start of our init.lua, because we use Oil
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

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
	show = function(_, _, _, opts)
		-- Generally don't want it to open on every update
		opts.loclist.open = opts.loclist.open or false
		local winid = vim.api.nvim_get_current_win()
		vim.diagnostic.setloclist(opts.loclist)
		vim.api.nvim_set_current_win(winid)
	end,
}

-- Disable diagnostics on insert mode (hack) https://github.com/neovim/neovim/issues/13324
vim.api.nvim_create_autocmd({ "BufNew", "InsertEnter" }, {
	-- or vim.api.nvim_create_autocmd({"BufNew", "TextChanged", "TextChangedI", "TextChangedP", "TextChangedT"}, {
	callback = function(args)
		vim.diagnostic.disable(args.buf)
	end,
})

vim.api.nvim_create_autocmd({ "BufWrite" }, {
	callback = function(args)
		vim.diagnostic.enable(args.buf)
	end,
})

vim.diagnostic.config({
	underline = true,
	signs = true,
	virtual_text = false,
	-- float = {
	-- 	show_header = true,
	-- 	source = "if_many",
	-- 	border = "rounded",
	-- 	focusable = false,
	-- },
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

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(event)
		local opts = { buffer = event.buf }
		-- vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
		vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
		vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
		vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
		vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
		vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
		vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
		vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
		vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
		vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
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

-- Local plugin Sliwez
-- vim.keymap.set('v', '<leader>s', require("sliwez").send_highlighted_text_to_next_pane)
-- vim.keymap.set('n', '<leader>s', require("sliwez").send_paragraph_text_to_next_pane)

vim.keymap.set({ 'n', 'v' }, '<leader>s', require("sliwez").send_lines_to_next_pane,
  { desc = 'Send selected lines or current line to configured wezterm pane' })

vim.cmd([[command LingNext lua require("sliwez").send_to_next_pane('n') ]])
vim.cmd([[command LingHint lua require("sliwez").send_to_next_pane('h') ]])

-----------------
--- EXPLORER ----
-----------------

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
		is_hidden_file = function(name, bufnr)
			local m = name:match("^%.")
			return m ~= nil
		end,
		is_always_hidden = function(name, bufnr)
			return false
		end,
	},
})

----------------
--- CUSTOM  ----
----------------

-- Compare the current buffer with the original file
vim.cmd([[command DiffOrig vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis | wincmd p | diffthis]])
