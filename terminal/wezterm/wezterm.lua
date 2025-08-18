-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

wezterm.on("gui-startup", function()
  local tab, pane, window = mux.spawn_window{}
  window:gui_window():maximize()
end)

-- and finally, return the configuration to wezterm

local keymaps = {
    { key = "a", mods = "LEADER|CTRL",  action=wezterm.action{SendString="\x01"}},
    { key = "-", mods = "LEADER",       action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}},
    { key = "|",mods = "LEADER",       action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
    { key = "s", mods = "LEADER",       action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}},
    { key = "v", mods = "LEADER",       action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
    { key = "c", mods = "LEADER",       action=wezterm.action{SpawnTab="CurrentPaneDomain"}},
    { key = "h", mods = "LEADER",       action=wezterm.action{ActivatePaneDirection="Left"}},
    { key = "j", mods = "LEADER",       action=wezterm.action{ActivatePaneDirection="Down"}},
    { key = "k", mods = "LEADER",       action=wezterm.action{ActivatePaneDirection="Up"}},
    { key = "l", mods = "LEADER",       action=wezterm.action{ActivatePaneDirection="Right"}},
    { key = "H", mods = "LEADER|SHIFT", action=wezterm.action{AdjustPaneSize={"Left", 5}}},
    { key = "J", mods = "LEADER|SHIFT", action=wezterm.action{AdjustPaneSize={"Down", 5}}},
    { key = "K", mods = "LEADER|SHIFT", action=wezterm.action{AdjustPaneSize={"Up", 5}}},
    { key = "L", mods = "LEADER|SHIFT", action=wezterm.action{AdjustPaneSize={"Right", 5}}},
    { key = "1", mods = "LEADER",       action=wezterm.action{ActivateTab=0}},
    { key = "2", mods = "LEADER",       action=wezterm.action{ActivateTab=1}},
    { key = "3", mods = "LEADER",       action=wezterm.action{ActivateTab=2}},
    { key = "4", mods = "LEADER",       action=wezterm.action{ActivateTab=3}},
    { key = "5", mods = "LEADER",       action=wezterm.action{ActivateTab=4}},
    { key = "6", mods = "LEADER",       action=wezterm.action{ActivateTab=5}},
    { key = "7", mods = "LEADER",       action=wezterm.action{ActivateTab=6}},
    { key = "8", mods = "LEADER",       action=wezterm.action{ActivateTab=7}},
    { key = "9", mods = "LEADER",       action=wezterm.action{ActivateTab=8}},
    { key = "&", mods = "LEADER|SHIFT", action=wezterm.action{CloseCurrentTab={confirm=true}}},
    { key = "d", mods = "LEADER",       action=wezterm.action{CloseCurrentPane={confirm=true}}},
    { key = "x", mods = "LEADER",       action=wezterm.action{CloseCurrentPane={confirm=true}}},
    { key = "z", mods = 'LEADER',       action=wezterm.action.TogglePaneZoomState},
    { key = "[", mods = 'LEADER',       action=wezterm.action.ActivateCopyMode},
    { key = "n", mods = 'LEADER',       action=wezterm.action.ActivateTabRelative(1)},
    { key = "p", mods = 'LEADER',       action=wezterm.action.ActivateTabRelative(-1)},
    { key = "w", mods = 'LEADER',       action=wezterm.action.ShowTabNavigator},
    { key = "a", mods = 'LEADER',       action=wezterm.action.ActivatePaneDirection('Next')},
    -- { key = "a", mods = 'LEADER',       action=wezterm.action.PaneSelect},
    {
        key = ",",
        mods = 'LEADER',
        action = act.PromptInputLine {
            description = 'Enter new name for tab',
            action = wezterm.action_callback(
                function(window, pane, line)
                    if line then
                        window:active_tab():set_title(line)
                    end
                end
            ),
        },
    },
}

local config = {
  font = wezterm.font_with_fallback({
    "ComicShannsMono Nerd Font",
  }),

  -- color_scheme = 'Builtin Light',
  -- color_scheme = 'zenbones',
  -- color_scheme = 'Alabaster',
  font_size = 12.0, -- Ideal for the office
  --font_size = 18.0, -- Ideal for the laptop
  leader = { key="a", mods="CTRL" },
  automatically_reload_config = true,
  use_fancy_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,
  keys = keymaps,
}


config.colors = {
  foreground = '#393736',
  background = '#FDFCFB',
  cursor_bg = '#2D2B2A',
  cursor_fg = '#FDFCFB',
  cursor_border = '#2D2B2A',
  selection_fg = '#393736',
  selection_bg = '#D4D1CF',
  scrollbar_thumb = '#E9E7E5',
  split = '#E2E0DE',

  ansi = {
    '#2D2B2A', -- black
    '#D75F5F', -- red
    '#5F875F', -- green
    '#D7875F', -- yellow
    '#5F87AF', -- blue
    '#AF87AF', -- magenta
    '#5E5C5A', -- cyan
    '#393736', -- white
  },
  brights = {
    '#5E5C5A', -- bright black
    '#D75F5F', -- bright red
    '#5F875F', -- bright green
    '#D7875F', -- bright yellow
    '#5F87AF', -- bright blue
    '#AF87AF', -- bright magenta
    '#5E5C5A', -- bright cyan
    '#393736', -- bright white
  },
}

return config
