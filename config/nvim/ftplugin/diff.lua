----------------------------------------------------------------------
-- Folding: one fold per file
----------------------------------------------------------------------

local function diff_foldexpr()
  local line = vim.fn.getline(vim.v.lnum)

  -- Start a fold at file headers
  if line:match("^diff %-%-git") or line:match("^Index: ") then
    return ">1"
  end

  -- Treat metadata lines as inside the current fold
  if line:match("^%-%-%- ") or line:match("^%+%+%+ ") or line:match("^index ") then
    return "1"
  end

  -- Everything else stays at the current level
  return "1"
end

vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr   = "v:lua.diff_foldexpr()"
_G.diff_foldexpr = diff_foldexpr

vim.opt_local.foldenable     = true
vim.opt_local.foldlevel      = 0
vim.opt_local.foldlevelstart = 0
vim.opt_local.foldcolumn     = "1"
vim.cmd("silent! normal! zx") -- recompute folds after setting expr
vim.cmd("silent! normal! zM") -- close all folds by default

----------------------------------------------------------------------
-- UI for diff buffers
----------------------------------------------------------------------

vim.opt_local.cursorline     = true
vim.opt_local.number         = true
vim.opt_local.relativenumber = true
vim.opt_local.signcolumn     = "yes"
vim.opt_local.wrap           = false

vim.opt_local.listchars = {
  tab = "» ",
  trail = "·",
  extends = ">",
  precedes = "<",
}

----------------------------------------------------------------------
-- Light-background diff colors
----------------------------------------------------------------------

-- Additions: light green
vim.api.nvim_set_hl(0, "DiffAdd", {
  bg = "#d6f5d6",  -- pastel green
  fg = "NONE",
})

-- Deletions: light red (pink-ish)
vim.api.nvim_set_hl(0, "DiffDelete", {
  bg = "#f8d0d0",  -- pastel red
  fg = "NONE",
})

-- Changes: light yellow/amber
vim.api.nvim_set_hl(0, "DiffChange", {
  bg = "#fff4bf",  -- pale yellow
  fg = "NONE",
})

-- Changed text (highlight inside lines)
vim.api.nvim_set_hl(0, "DiffText", {
  bg = "#ffe899",  -- slightly darker yellow
  fg = "NONE",
})

----------------------------------------------------------------------
-- Navigation: jump by file & hunk
----------------------------------------------------------------------

vim.keymap.set("n", "]f", "/^diff --git<CR>", { buffer = true, silent = true })
vim.keymap.set("n", "[f", "?^diff --git<CR>", { buffer = true, silent = true })
vim.keymap.set("n", "]h", "/^@@<CR>",         { buffer = true, silent = true })
vim.keymap.set("n", "[h", "?^@@<CR>",         { buffer = true, silent = true })

----------------------------------------------------------------------
-- TagBar-like outline using the location list (no plugins)
----------------------------------------------------------------------

local function build_diff_loclist()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local items = {}

  for i, line in ipairs(lines) do
    -- FILE header
    local a, b = line:match("^diff %-%-git a/(.+) b/(.+)")
    if b then
      table.insert(items, {
        bufnr = bufnr,
        lnum = i,
        col = 1,
        text = "FILE: " .. b,
      })
    else
      -- HUNK header
      local new_start = line:match("^@@ %-%d+,?%d* +(%d+)")
      if new_start then
        table.insert(items, {
          bufnr = bufnr,
          lnum = i,
          col = 1,
          text = "HUNK: +" .. new_start,
        })
      end
    end
  end

  if #items == 0 then
    print("No diff headers found.")
    return
  end

  vim.fn.setloclist(0, {}, "r", { title = "Diff outline", items = items })
  vim.cmd("lopen")
end

vim.keymap.set(
  "n",
  "<leader>do",
  build_diff_loclist,
  { buffer = true, silent = true, desc = "Diff outline (files/hunks)" }
)

----------------------------------------------------------------------
-- Aerial symbols (files + hunks)
----------------------------------------------------------------------

local function set_aerial_symbols()
  local ok_backends, backends = pcall(require, "aerial.backends")
  local ok_config, aconfig = pcall(require, "aerial.config")
  if not ok_backends or not ok_config or type(aconfig) ~= "table" then
    return
  end

  -- Fallbacks for older aerial versions or missing fields
  if type(aconfig.manage_folds) ~= "function" then
    aconfig.manage_folds = function()
      return false
    end
  end
  if aconfig.layout == nil then
    aconfig.layout = { default_direction = "prefer_right" }
  end

  -- Backward compatibility: aerial.config.manage_folds may be nil on older versions
  -- (already handled above)

  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local symbols = {}

  for i, line in ipairs(lines) do
    local a_path, b_path = line:match("^diff %-%-git +a/(.+) +b/(.+)")
    if b_path then
      local name = b_path
      table.insert(symbols, {
        name = name,
        kind = "File",
        lnum = i,
        col = 0,
        end_lnum = i,
        end_col = 0,
        level = 0,
        children = {},
      })
    else
      local hunk = line:match("^@@ +%-%d+,?%d* +(%d+)")
      if hunk then
        table.insert(symbols, {
          name = "Hunk +" .. hunk,
          kind = "Section",
          lnum = i,
          col = 0,
          end_lnum = i,
          end_col = 0,
          level = 1,
          children = {},
        })
      end
    end
  end

  if #symbols == 0 then
    return
  end

  pcall(backends.set_symbols, bufnr, symbols, { backend_name = "diff", lang = "diff" })
  pcall(vim.api.nvim_buf_set_var, bufnr, "aerial_backend", "diff")

  -- Ask Aerial to refresh visibility
  local ok_auto, auto = pcall(require, "custom.aerial_auto")
  if ok_auto then
    auto.refresh(bufnr)
  end
end

vim.defer_fn(set_aerial_symbols, 30)
