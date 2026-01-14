#!/usr/bin/env bash
set -euo pipefail

# Show staged/unstaged status and, if needed, offer to add everything
STAGED="$(git diff --cached --name-status)"
UNSTAGED="$(git diff --name-status)"
UNTRACKED="$(git ls-files --others --exclude-standard)"

if [ -n "$STAGED" ]; then
  echo "Staged files:"
  printf '%s\n' "$STAGED"
fi

if [ -n "$UNSTAGED" ] || [ -n "$UNTRACKED" ]; then
  if [ -n "$UNSTAGED" ]; then
    echo "Unstaged files:"
    printf '%s\n' "$UNSTAGED"
  fi
  if [ -n "$UNTRACKED" ]; then
    echo "Untracked files:"
    printf '%s\n' "$UNTRACKED"
  fi
  read -r -p "Add all unstaged/untracked files to this commit? [y/N] " RESP
  case "$RESP" in
    [yY]|[yY][eE][sS]) git add -A ;;
  esac
fi

# Use staged changes by default
if git diff --cached --quiet; then
  echo "No staged changes. Run 'git add' before using this script."
  exit 1
fi

PROMPT='Write a Conventional Commits message from the diff.

Rules:
- Format: <type>(<scope>): <short summary>
  - Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore.
  - <scope> only if clearly inferable.
- Summary < 72 chars, imperative.
- Blank line, then a brief body (1-3 lines). Use bullets if it helps.
- Do not wrap the message in ** or add ** at the beginning or end.
- Only use the provided diff. Output only the message.'

# Generate initial commit message with Codex from staged diff, suppressing noisy console output
TMP_MSG="$(mktemp)"
TMP_ERR="$(mktemp)"
set +o pipefail
if ! git diff --cached -U2 | codex exec -m gpt-5.1-codex-mini --output-last-message "$TMP_MSG" "$PROMPT" >/dev/null 2>"$TMP_ERR"; then
  echo "Failed to generate commit message:"
  cat "$TMP_ERR"
  rm -f "$TMP_MSG" "$TMP_ERR"
  exit 1
fi
set -o pipefail
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
