#!/usr/bin/env bash
set -euo pipefail

# Accept PR number as argument or detect from current branch
if [ $# -ge 1 ]; then
  PR="$1"
else
  PR="$(gh pr view --json number -q '.number' 2>/dev/null || true)"
  if [ -z "$PR" ]; then
    echo "No PR found for the current branch. Pass a PR number as argument."
    exit 1
  fi
fi

REPO="$(gh repo view --json nameWithOwner -q '.nameWithOwner')"
OUTPUT="review-output.md"

echo "Gathering feedback for $REPO#$PR ..."

# PR metadata
PR_JSON="$(gh pr view "$PR" --json title,body,state,url,author,baseRefName,headRefName,createdAt,updatedAt)"
TITLE="$(printf '%s' "$PR_JSON" | jq -r '.title')"
URL="$(printf '%s' "$PR_JSON" | jq -r '.url')"
STATE="$(printf '%s' "$PR_JSON" | jq -r '.state')"
AUTHOR="$(printf '%s' "$PR_JSON" | jq -r '.author.login')"
BASE="$(printf '%s' "$PR_JSON" | jq -r '.baseRefName')"
HEAD="$(printf '%s' "$PR_JSON" | jq -r '.headRefName')"
BODY="$(printf '%s' "$PR_JSON" | jq -r '.body')"

# Reviews
REVIEWS="$(gh api "repos/$REPO/pulls/$PR/reviews" --paginate)"

# Review comments (inline comments on diffs)
REVIEW_COMMENTS="$(gh api "repos/$REPO/pulls/$PR/comments" --paginate)"

# Issue comments (general PR conversation)
ISSUE_COMMENTS="$(gh api "repos/$REPO/issues/$PR/comments" --paginate)"

# Check runs (CI/CD workflows)
HEAD_SHA="$(gh pr view "$PR" --json commits --jq '.commits[-1].oid')"
CHECK_RUNS="$(gh api "repos/$REPO/commits/$HEAD_SHA/check-runs" --paginate)"

# Build the output
{
  echo "# PR Review: $TITLE"
  echo ""
  echo "- **URL:** $URL"
  echo "- **State:** $STATE"
  echo "- **Author:** $AUTHOR"
  echo "- **Branch:** $HEAD → $BASE"
  echo ""
  echo "## Description"
  echo ""
  echo "$BODY"
  echo ""

  # Reviews summary
  echo "## Reviews"
  echo ""
  REVIEW_COUNT="$(printf '%s' "$REVIEWS" | jq 'length')"
  if [ "$REVIEW_COUNT" -eq 0 ]; then
    echo "No reviews yet."
  else
    printf '%s' "$REVIEWS" | jq -r '.[] | "### \(.user.login) — \(.state)\n\n\(.body // "_No comment body._")\n"'
  fi
  echo ""

  # Review comments (inline on diffs)
  echo "## Inline Comments"
  echo ""
  REVIEW_COMMENT_COUNT="$(printf '%s' "$REVIEW_COMMENTS" | jq 'length')"
  if [ "$REVIEW_COMMENT_COUNT" -eq 0 ]; then
    echo "No inline comments."
  else
    printf '%s' "$REVIEW_COMMENTS" | jq -r '.[] | "### \(.user.login) on `\(.path)`\(.line // "" | if . == "" then "" else " (line \(.))" end)\n\n\(.body)\n"'
  fi
  echo ""

  # Issue comments (conversation)
  echo "## Conversation"
  echo ""
  ISSUE_COMMENT_COUNT="$(printf '%s' "$ISSUE_COMMENTS" | jq 'length')"
  if [ "$ISSUE_COMMENT_COUNT" -eq 0 ]; then
    echo "No conversation comments."
  else
    printf '%s' "$ISSUE_COMMENTS" | jq -r '.[] | "### \(.user.login)\n\n\(.body)\n"'
  fi
  echo ""

  # CI/CD check runs
  echo "## Workflow Runs"
  echo ""
  CHECK_COUNT="$(printf '%s' "$CHECK_RUNS" | jq '.check_runs | length')"
  if [ "$CHECK_COUNT" -eq 0 ]; then
    echo "No check runs found."
  else
    printf '%s' "$CHECK_RUNS" | jq -r '.check_runs[] | "- **\(.name)**: \(.conclusion // .status) \(if .conclusion != null and .conclusion != "success" then "⚠" else "" end)"'
    echo ""

    # Show details for failed checks
    FAILED="$(printf '%s' "$CHECK_RUNS" | jq '[.check_runs[] | select(.conclusion != null and .conclusion != "success" and .conclusion != "skipped")]')"
    FAILED_COUNT="$(printf '%s' "$FAILED" | jq 'length')"
    if [ "$FAILED_COUNT" -gt 0 ]; then
      echo "### Failed / Non-Success Checks"
      echo ""
      printf '%s' "$FAILED" | jq -r '.[] | "#### \(.name) — \(.conclusion)\n\n- **URL:** \(.html_url)\n- **Output:** \(.output.title // "_No title_")\n\n\(.output.summary // "_No summary._")\n"'
    fi
  fi
} > "$OUTPUT"

echo "Done. Review saved to $OUTPUT"
