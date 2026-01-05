#!/bin/bash
# Capture content from a zellij pane by name
# Usage: zellij-pane.sh <pane-name>

TARGET="${1:-}"

# Helper to extract command names from layout (portable, no -P)
extract_commands() {
    sed -n 's/.*command="\([^"]*\)".*/\1/p' | sort -u
}

# Helper to find the command of the currently focused pane
get_focused_command() {
    local layout="$1"
    # Find the line with both "pane command=" and "focus=true"
    echo "$layout" | grep 'pane command=.*focus=true' | sed -n 's/.*command="\([^"]*\)".*/\1/p' | head -1
}

if [ -z "$TARGET" ]; then
    echo "Usage: zellij-pane.sh <pane-name>"
    echo ""
    echo "Available panes:"
    zellij action dump-layout 2>/dev/null | extract_commands
    exit 0
fi

FOUND=0

for i in 1 2 3 4 5 6 7 8; do
    LAYOUT=$(zellij action dump-layout 2>/dev/null)
    FOCUSED_CMD=$(get_focused_command "$LAYOUT")

    if echo "$FOCUSED_CMD" | grep -qi "$TARGET"; then
        TMPFILE=$(mktemp)
        zellij action dump-screen "$TMPFILE"
        cat "$TMPFILE"
        rm -f "$TMPFILE"
        FOUND=1
        break
    fi

    zellij action focus-next-pane 2>/dev/null
    sleep 0.15
done

if [ $FOUND -eq 0 ]; then
    echo "Pane '$TARGET' not found. Available:"
    zellij action dump-layout 2>/dev/null | extract_commands
fi
