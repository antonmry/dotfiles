#!/bin/bash
# Claude Code notification script
# Usage: notify.sh "title" "message"

TITLE="${1:-Claude Code}"
MESSAGE="${2:-Notification}"

if command -v osascript &>/dev/null; then
    # macOS
    osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\""
elif command -v notify-send &>/dev/null; then
    # Linux
    notify-send "$TITLE" "$MESSAGE"
else
    echo "[$TITLE] $MESSAGE" >&2
fi
