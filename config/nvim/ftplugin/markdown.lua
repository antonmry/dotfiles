
-- ~/.config/nvim/ftplugin/markdown.lua

------------------------------------------------------------
-- Formatter (conform.nvim)
------------------------------------------------------------
require("conform").formatters_by_ft.markdown = { "rumdl" }

------------------------------------------------------------
-- Linter (nvim-lint)
------------------------------------------------------------
require("lint").linters_by_ft.markdown = { "rumdl" }

------------------------------------------------------------
-- LSP: markdown-oxide, only for Obsidian vault paths
------------------------------------------------------------
local fname = vim.api.nvim_buf_get_name(0)
if fname == "" or not fname:lower():match("obsidian") then
  return
end

if vim.fn.executable("markdown-oxide") == 0 then
  vim.notify("[markdown_oxide] binary not found in PATH", vim.log.levels.WARN)
  return
end

-- Capabilities (enable dynamicRegistration for file watching)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.workspace = capabilities.workspace or {}
capabilities.workspace.didChangeWatchedFiles =
  capabilities.workspace.didChangeWatchedFiles or {}
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true

-- Find vault root: look upwards for a marker
local function find_root(path)
  local markers = { ".moxide.toml", ".obsidian", ".git" }
  local root = vim.fs.find(markers, { path = path, upward = true })[1]
  if root then
    return vim.fs.dirname(root)
  end
  -- Fallback: directory of the current file
  return vim.fs.dirname(path)
end

local root_dir = find_root(fname)

-- Helper: send "jump" command to the markdown_oxide client
local function oxide_jump(arg)
  -- New API: get_clients (replaces deprecated get_active_clients)
  local clients = vim.lsp.get_clients({
    bufnr = 0,                -- current buffer
    name = "markdown_oxide",
  })

  local client = clients[1]
  if not client then
    vim.notify("[markdown_oxide] no active client for jump", vim.log.levels.WARN)
    return
  end

  client:request(
    "workspace/executeCommand",
    { command = "jump", arguments = { arg } },
    nil,
    0
  )
end

local function on_attach(client, bufnr)
  -- Built-in LSP completion: <C-x><C-o>
  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

  if client.name == "markdown_oxide" then
    -- :Daily command (define once, uses oxide_jump)
    if not vim.g.markdown_oxide_daily_defined then
      vim.api.nvim_create_user_command("Daily", function(args)
        local target = args.args
        if target == "" then
          target = "today"
        end
        oxide_jump(target)
      end, { desc = "Open daily note", nargs = "*" })
      vim.g.markdown_oxide_daily_defined = true
    end

    -- Shortcuts:
    --   <leader>t → today
    --   <leader>T → yesterday
    vim.keymap.set("n", "<leader>t", function()
      oxide_jump("today")
    end, { buffer = bufnr, desc = "Daily: today" })

    vim.keymap.set("n", "<leader>T", function()
      oxide_jump("yesterday")
    end, { buffer = bufnr, desc = "Daily: yesterday" })

    -- Semantic tokens (for better highlighting, if supported)
    if client.server_capabilities.semanticTokensProvider then
      vim.lsp.semantic_tokens.enable(true, { bufnr = bufnr })
    end
  end
end

vim.lsp.start({
  name = "markdown_oxide",
  cmd = { "markdown-oxide" },
  root_dir = root_dir,
  capabilities = capabilities,
  on_attach = on_attach,
})

------------------------------------------------------------
-- Diagnostics styling for unresolved links (INFO severity)
------------------------------------------------------------
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", {
  undercurl = true,
  sp = "#ff0000", -- underline color
})

vim.api.nvim_set_hl(0, "DiagnosticInfo", {
  fg = "#b00000",
})

vim.diagnostic.config({
  underline = true,
  virtual_text = {
    severity = { min = vim.diagnostic.severity.INFO },
    prefix = "",
  },
})

local function set_hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

------------------------------------------------------------
-- Wikilinks from markdown-oxide (Obsidian-style [[...]])
-- Semantic token: @lsp.type.decorator.markdown
------------------------------------------------------------
set_hl("@lsp.type.decorator.markdown", {
  fg = "#4a6fa5",      -- soft desaturated blue
  underline = true,
})

------------------------------------------------------------
-- Tree-sitter markup link groups (normal Markdown links)
------------------------------------------------------------

-- Generic link text [label](url)
set_hl("@markup.link.markdown", {
  fg = "#4f6d88",      -- muted blue-grey
})

-- Explicit label part inside links
set_hl("@markup.link.label.markdown", {
  fg = "#4f6d88",
})

-- URL / destination part (https://..., mailto:, etc.)
set_hl("@markup.link.url.markdown", {
  fg = "#5b7a5a",      -- soft olive green
})

-- Image / embed alt text ![alt](...)
set_hl("@markup.link.image.markdown", {
  fg = "#6a5f86",      -- soft muted violet
})

-- Fallback for any other markup.link nodes
set_hl("@markup.link", {
  fg = "#4f6d88",
})
