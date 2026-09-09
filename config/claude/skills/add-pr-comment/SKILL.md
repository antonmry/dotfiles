---
name: add-pr-comment
description: Post a single inline review comment to a GitHub PR via the add-pr-comment.sh helper. Use when the user asks to comment on a specific file/line of a PR, leave PR feedback inline, or annotate a diff line — not for overall PR reviews (approve/request-changes).
---

# Add PR Comment

Post a single inline review comment to a GitHub PR using `add-pr-comment.sh`.

The script is installed on `PATH` (lives in `~/bin/add-pr-comment.sh`, symlinked
from `~/.dotfiles/bin/add-pr-comment.sh`). It is **not** co-located with this
`SKILL.md` — invoke it by its bare name `add-pr-comment.sh`, not by a path
under `~/.claude/skills/`.

## When to use

- User asks to leave an inline comment on a PR file/line.
- User asks to annotate a specific line in a diff.
- You want to surface a concrete finding tied to a file:line during a PR review.

Do **not** use for:
- Overall PR review (approve / request-changes / comment) — use `gh pr review`.
- Bulk inline comments authored in an editor — use `review.sh` with `// GH:` markers.
- General PR conversation — use `gh pr comment`.

## Usage

```bash
add-pr-comment.sh <PR> <file> <line> [body]
add-pr-comment.sh <PR> <file> <start_line>-<end_line> [body]
echo "body" | add-pr-comment.sh <PR> <file> <line>
```

The script auto-detects `OWNER/REPO` from `git config remote.origin.url` and
uses the PR's HEAD commit as `commit_id`. Comments are posted on the RIGHT
side of the diff (added or context lines).

Run `add-pr-comment.sh --help` for the full help text.

## Workflow for agents

1. **Find valid lines.** Only lines present in the PR diff (added or context)
   accept comments. Run:
   ```bash
   gh pr diff <PR>
   ```
   to see the file paths and line ranges that are commentable.

   **Important:** the `<line>` argument is the line number in the NEW file
   (post-image) — i.e., what your editor shows when viewing the file at the
   PR's head. It is **not** the line number in `gh pr diff` output, which
   includes hunk headers and removed lines that shift the count. To get the
   right number reliably, fetch the file at the head ref and use that line
   number. For example:
   ```bash
   head_sha=$(gh pr view <PR> --json headRefOid --jq .headRefOid)
   gh api "repos/<owner>/<repo>/contents/<file>?ref=$head_sha" \
       --jq '.content' | base64 -d | grep -n '<pattern>'
   ```

2. **Post one comment per finding.** Keep each comment focused on one issue.
   For multi-line context, use `start-end` line spec.

3. **Use stdin or a heredoc for multi-line bodies** — the 4th positional arg
   is fine for short comments, but heredocs are cleaner for prose:
   ```bash
   add-pr-comment.sh 123 src/foo.rs 42 <<'MSG'
   Nit: this branch is unreachable because `validate()` already
   rejects empty input. Safe to remove.
   MSG
   ```

4. **Check the exit code.** A non-zero exit usually means the line is not in
   the diff, the PR number is wrong, or `gh` is not authenticated.

## Examples

```bash
# Single-line, short body
add-pr-comment.sh 123 src/foo.rs 42 "this allocates twice"

# Multi-line range, body via stdin
echo "consider extracting this into a helper" \
    | add-pr-comment.sh 123 src/foo.rs 40-55

# Heredoc for prose
add-pr-comment.sh 123 src/foo.rs 42 <<'MSG'
This lock is held across an `await`, which can deadlock if the
runtime schedules another task that also wants this lock.
MSG
```

## Related tools

- `review.sh` — bulk inline comments via `// GH:` markers in an editor.
- `get-pr-feedback.sh` — dump all reviews/comments/checks of a PR to markdown.
- `gh pr review` — overall PR review (approve / request-changes / comment).
- `gh pr comment` — top-level conversation comment (not inline).
