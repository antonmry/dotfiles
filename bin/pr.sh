#!/usr/bin/env bash
set -euo pipefail

# Determine base branch (main or master)
BASE="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')" || true
if [ -z "$BASE" ]; then
  if git show-ref --verify --quiet refs/remotes/origin/main; then
    BASE="main"
  elif git show-ref --verify --quiet refs/remotes/origin/master; then
    BASE="master"
  else
    echo "Cannot determine base branch."
    exit 1
  fi
fi

BRANCH="$(git branch --show-current)"
if [ "$BRANCH" = "$BASE" ]; then
  echo "You are on '$BASE'. Switch to a feature branch first."
  exit 1
fi

# Warn about unstaged/untracked files
UNSTAGED="$(git diff --name-status)"
UNTRACKED="$(git ls-files --others --exclude-standard)"

if [ -n "$UNSTAGED" ] || [ -n "$UNTRACKED" ]; then
  if [ -n "$UNSTAGED" ]; then
    echo "Unstaged files:"
    printf '%s\n' "$UNSTAGED"
  fi
  if [ -n "$UNTRACKED" ]; then
    echo "Untracked files:"
    printf '%s\n' "$UNTRACKED"
  fi
  read -r -p "Continue without these files? [y/N] " RESP
  case "$RESP" in
    [yY]|[yY][eE][sS]) ;;
    *) echo "Aborted."; exit 1 ;;
  esac
fi

# Check for commits ahead of base
COMMITS="$(git log "$BASE"..HEAD --oneline)"
if [ -z "$COMMITS" ]; then
  echo "No commits ahead of '$BASE'. Nothing to open a PR for."
  exit 1
fi

echo "Commits to include:"
printf '%s\n' "$COMMITS"
echo ""

# Check if a PR already exists for this branch
EXISTING_PR="$(gh pr view "$BRANCH" --json number,url 2>/dev/null || true)"
EXISTING_PR_NUM=""
EXISTING_PR_URL=""
if [ -n "$EXISTING_PR" ]; then
  EXISTING_PR_NUM="$(printf '%s' "$EXISTING_PR" | jq -r '.number')"
  EXISTING_PR_URL="$(printf '%s' "$EXISTING_PR" | jq -r '.url')"
fi

# Build diff for the prompt
DIFF="$(git diff "$BASE"...HEAD -U2)"

PROMPT='Write a GitHub Pull Request title and description from the diff and commit log.

Rules:
- First line: a short PR title (< 72 chars, imperative mood).
- Blank line, then a markdown body:
  - ## Summary section with 1-3 bullet points.
  - ## Test plan section with a bulleted checklist of testing steps.
- Do not wrap text in ** or add ** at the beginning or end.
- Only use the provided diff and commit log. Output only the PR message.'

# Generate PR message with Codex
TMP_MSG="$(mktemp)"
TMP_ERR="$(mktemp)"
TMP_INPUT="$(mktemp)"

printf '%s\n\n--- Commits ---\n%s\n\n--- Diff ---\n%s' "$PROMPT" "$COMMITS" "$DIFF" > "$TMP_INPUT"

echo "Generating PR message..."
set +o pipefail
if ! cat "$TMP_INPUT" | codex exec -m gpt-5-codex -c 'model_reasoning_effort="medium"' --output-last-message "$TMP_MSG" "$PROMPT" >/dev/null 2>"$TMP_ERR"; then
  echo "Failed to generate PR message:"
  cat "$TMP_ERR"
  rm -f "$TMP_MSG" "$TMP_ERR" "$TMP_INPUT"
  exit 1
fi
set -o pipefail
rm -f "$TMP_ERR" "$TMP_INPUT"

# Let the user edit in nvim (or $EDITOR if set)
"${EDITOR:-nvim}" "$TMP_MSG"

# If the file is empty after editing, abort
if [ ! -s "$TMP_MSG" ]; then
  echo "Aborted: PR message is empty."
  rm -f "$TMP_MSG"
  exit 1
fi

# Parse title (first line) and body (rest)
TITLE="$(head -n 1 "$TMP_MSG")"
BODY="$(tail -n +3 "$TMP_MSG")"

if [ -z "$TITLE" ]; then
  echo "Aborted: PR title is empty."
  rm -f "$TMP_MSG"
  exit 1
fi

if [ -n "$EXISTING_PR_NUM" ]; then
  # PR already exists — update
  echo ""
  echo "PR #$EXISTING_PR_NUM already exists: $EXISTING_PR_URL"
  read -r -p "Force-push and update PR description? [y/N] " RESP
  case "$RESP" in
    [yY]|[yY][eE][sS]) ;;
    *) echo "Aborted."; rm -f "$TMP_MSG"; exit 1 ;;
  esac

  git push --force-with-lease
  gh pr edit "$EXISTING_PR_NUM" --title "$TITLE" --body "$BODY"
  echo "Updated PR #$EXISTING_PR_NUM: $EXISTING_PR_URL"
else
  # Push and create new PR
  git push -u origin "$BRANCH"
  gh pr create --title "$TITLE" --body "$BODY"
fi

# Cleanup
rm -f "$TMP_MSG"
