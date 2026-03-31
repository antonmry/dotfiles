#!/bin/bash
# Capture content from a zellij pane by name (current tab only)
# Usage: zellij-pane.sh <pane-name>
# Requires: zellij >= 0.44.0, jq

TARGET="${1:-}"

# Get all panes and determine the current tab
get_panes_json() {
    zellij action list-panes --json --all 2>/dev/null
}

current_tab() {
    jq -r '[.[] | select(.is_focused == true)] | .[0].tab_position'
}

# List pane commands in a given tab
list_pane_commands() {
    local tab="$1"
    jq -r --arg tab "$tab" \
        '.[] | select(.tab_position == ($tab | tonumber))
             | .pane_command // .title // "unnamed"' | sort -u
}

# Find pane ID matching target name (case-insensitive) in a given tab
find_pane_id() {
    local tab="$1" target="$2"
    jq -r --arg tab "$tab" --arg t "$target" \
        '.[] | select(.tab_position == ($tab | tonumber))
             | select(
                 ((.pane_command // "") | ascii_downcase | contains($t | ascii_downcase))
                 or ((.title // "") | ascii_downcase | contains($t | ascii_downcase)))
             | .id' | head -1
}

PANES=$(get_panes_json)
TAB=$(echo "$PANES" | current_tab)

if [ -z "$TARGET" ]; then
    echo "Usage: zellij-pane.sh <pane-name>"
    echo ""
    echo "Available panes (current tab):"
    echo "$PANES" | list_pane_commands "$TAB"
    exit 0
fi

PANE_ID=$(echo "$PANES" | find_pane_id "$TAB" "$TARGET")

if [ -z "$PANE_ID" ]; then
    echo "Pane '$TARGET' not found in current tab. Available:"
    echo "$PANES" | list_pane_commands "$TAB"
    exit 1
fi

zellij action dump-screen --pane-id "$PANE_ID"
