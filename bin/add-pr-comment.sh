#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
add-pr-comment.sh — post a single inline review comment to a GitHub PR.

USAGE
    add-pr-comment.sh <PR> <file> <line> [body]
    add-pr-comment.sh <PR> <file> <start_line>-<end_line> [body]
    echo "body" | add-pr-comment.sh <PR> <file> <line>

ARGUMENTS
    PR          PR number (e.g. 123).
    file        Path to the file as it appears in the PR (e.g. src/foo.rs).
    line        Line number in the NEW file (post-image, RIGHT side of the
                diff) — i.e., the line number an editor shows when viewing
                the file at the PR's head ref. NOT the line number in
                `gh pr diff` output (which includes hunk headers and removed
                lines, shifting the count).
                Use START-END for a multi-line comment (e.g. 10-15).
    body        Comment body. If omitted, read from stdin.

BEHAVIOR
    - OWNER/REPO is auto-detected from `git config remote.origin.url`.
    - The PR's HEAD commit SHA is used as commit_id.
    - The comment is posted on the RIGHT side (added/context lines).
      To comment on a removed line, you must edit the API call manually.
    - Exits non-zero if the API call fails (e.g. line not in diff).

EXAMPLES
    # Single-line comment, body inline
    add-pr-comment.sh 123 src/foo.rs 42 "this allocates twice"

    # Multi-line comment via stdin
    echo "consider extracting this into a helper" \
        | add-pr-comment.sh 123 src/foo.rs 40-55

    # Heredoc for a longer comment
    add-pr-comment.sh 123 src/foo.rs 42 <<'MSG'
    Nit: this branch is unreachable because `validate()` already
    rejects empty input. Safe to remove.
    MSG

NOTES FOR AGENTS
    - Run `gh pr diff <PR>` first to find valid file paths and line numbers.
      Only lines that appear in the diff (added or context) accept comments.
    - For an overall PR review (approve / request-changes / comment),
      use `gh pr review` instead.
    - For bulk inline comments via a `// GH:` marker workflow, use review.sh.
EOF
}

if [[ $# -lt 1 || "$1" == "-h" || "$1" == "--help" ]]; then
    usage
    exit 0
fi

if [[ $# -lt 3 ]]; then
    echo "Error: missing required arguments." >&2
    echo "" >&2
    usage >&2
    exit 1
fi

PR="$1"
FILE="$2"
LINE_SPEC="$3"
BODY="${4:-}"

if [[ -z "$BODY" ]]; then
    if [[ -t 0 ]]; then
        echo "Error: no body given and stdin is a tty." >&2
        exit 1
    fi
    BODY=$(cat)
fi

if [[ -z "$BODY" ]]; then
    echo "Error: empty comment body." >&2
    exit 1
fi

# Parse line spec: either "N" or "N-M"
START_LINE=""
END_LINE=""
if [[ "$LINE_SPEC" =~ ^([0-9]+)-([0-9]+)$ ]]; then
    START_LINE="${BASH_REMATCH[1]}"
    END_LINE="${BASH_REMATCH[2]}"
elif [[ "$LINE_SPEC" =~ ^[0-9]+$ ]]; then
    END_LINE="$LINE_SPEC"
else
    echo "Error: invalid line spec '$LINE_SPEC' (expected N or N-M)." >&2
    exit 1
fi

remote_url=$(git config --get remote.origin.url)
OWNER=$(echo "$remote_url" | sed -E 's|.*github.com[:/]||; s|/.*||')
REPO=$(echo "$remote_url" | sed -E 's|.*github.com[:/]([^/]+)/([^./]+).*|\2|')

if [[ -z "$OWNER" || -z "$REPO" ]]; then
    echo "Error: cannot detect OWNER/REPO from remote.origin.url=$remote_url" >&2
    exit 1
fi

commit_id=$(gh pr view "$PR" --json headRefOid --jq '.headRefOid')

args=(
    --method POST
    "repos/$OWNER/$REPO/pulls/$PR/comments"
    -f body="$BODY"
    -f commit_id="$commit_id"
    -f path="$FILE"
    -F line="$END_LINE"
    -f side=RIGHT
)

if [[ -n "$START_LINE" ]]; then
    args+=(-F start_line="$START_LINE" -f start_side=RIGHT)
fi

if output=$(gh api "${args[@]}" 2>&1); then
    url=$(echo "$output" | jq -r '.html_url // empty' 2>/dev/null || true)
    if [[ -n "$url" ]]; then
        echo "Posted: $url"
    else
        echo "Posted comment on $FILE:$LINE_SPEC"
    fi
else
    echo "Error posting comment: $output" >&2
    if echo "$output" | grep -q "pull_request_review_thread.line"; then
        cat >&2 <<'HINT'

Hint: <line> must be the line number in the NEW file (post-image), NOT the
      line number in 'gh pr diff' output. The diff output includes hunk
      headers and removed lines, which shift the count.

      To find the right line, fetch the file at the PR's head ref:
          head_sha=$(gh pr view <PR> --json headRefOid --jq .headRefOid)
          gh api "repos/<owner>/<repo>/contents/<file>?ref=$head_sha" \
              --jq '.content' | base64 -d | grep -n '<pattern>'
HINT
    fi
    exit 1
fi
