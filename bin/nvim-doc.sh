#!/bin/bash
# Fetch Neovim documentation for a given help topic
# Usage: nvim-doc.sh <topic>
# Example: nvim-doc.sh lsp, nvim-doc.sh news, nvim-doc.sh pack

TOPIC="${1:-news}"

# Get VIMRUNTIME and find the doc file
VIMRUNTIME=$(nvim --clean --headless -c 'echo $VIMRUNTIME' -c 'qa!' 2>&1 | tr -d '\r\n')

# Common doc file patterns
DOC_FILE="$VIMRUNTIME/doc/${TOPIC}.txt"

if [[ -f "$DOC_FILE" ]]; then
    cat "$DOC_FILE"
else
    # Try to find it with a broader search
    FOUND=$(find "$VIMRUNTIME/doc" -name "*.txt" -exec grep -l "^\*${TOPIC}\*" {} \; 2>/dev/null | head -1)
    if [[ -n "$FOUND" ]]; then
        cat "$FOUND"
    else
        echo "Topic '$TOPIC' not found. Available docs:"
        ls "$VIMRUNTIME/doc/"*.txt 2>/dev/null | xargs -n1 basename | sed 's/\.txt$//' | sort | head -20
    fi
fi
