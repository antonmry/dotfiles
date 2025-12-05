#!/usr/bin/env bash
set -euo pipefail

# Use staged changes by default
if git diff --cached --quiet; then
  echo "No staged changes. Run 'git add' before using this script."
  exit 1
fi

PROMPT='You are an assistant that writes git commit messages in Conventional Commits format.

Requirements:
- Start with: <type>(<scope>): <short summary>
  - Valid types: feat, fix, docs, style, refactor, perf, test, build, ci, chore.
  - <scope> is optional. Use it only if it is clearly inferable from the diff.
- First line under 72 characters, imperative mood (e.g., "feat(api): add user search").
- Then a blank line.
- Then a more elaborate body explaining what changed and why.
  - Use bullet points if helpful.
  - Mention important files or modules if relevant.
- Base the message only on the provided git diff.
- Output ONLY the commit message text, nothing else.'

# Generate initial commit message with Codex from staged diff, suppressing noisy console output
TMP_MSG="$(mktemp)"
TMP_ERR="$(mktemp)"
if ! git diff --cached | codex exec --output-last-message "$TMP_MSG" "$PROMPT" >/dev/null 2>"$TMP_ERR"; then
  echo "Failed to generate commit message:"
  cat "$TMP_ERR"
  rm -f "$TMP_MSG" "$TMP_ERR"
  exit 1
fi
rm -f "$TMP_ERR"

# Let the user edit in nvim (or $EDITOR if set)
"${EDITOR:-nvim}" "$TMP_MSG"

# If the file is empty after editing, abort
if [ ! -s "$TMP_MSG" ]; then
  echo "Aborted: commit message is empty."
  rm -f "$TMP_MSG"
  exit 1
fi

# Use the edited file as the commit message
git commit -F "$TMP_MSG"

# Cleanup
rm -f "$TMP_MSG"
