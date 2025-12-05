#!/usr/bin/env bash
set -euo pipefail

# CONFIG ----------------------------
DIFF_FILE="review.diff"
PREFIX="// GH:"
SEP=$'\x1f'
# ensure diff is cleaned up after the script ends
cleanup() { rm -f "$DIFF_FILE"; }
trap cleanup EXIT
# -----------------------------------

############################################
# 1. Detect OWNER + REPO from git remote
############################################
remote_url=$(git config --get remote.origin.url)

OWNER=$(echo "$remote_url" | sed -E 's|.*github.com[:/]| |; s|/.*||' | awk '{print $1}')
REPO=$(echo "$remote_url"  | sed -E 's|.*github.com[:/]([^/]+)/([^./]+).*|\2|')

if [[ -z "$OWNER" || -z "$REPO" ]]; then
    echo "❌ Cannot detect OWNER/REPO from remote.origin.url=$remote_url"
    exit 1
fi

############################################
# 2. Detect PR number
############################################
PR="${1:-}"

if [[ -z "$PR" ]]; then
    branch=$(git rev-parse --abbrev-ref HEAD)

    if [[ "$branch" =~ ^pr/([0-9]+) ]]; then
        PR="${BASH_REMATCH[1]}"
    elif [[ "$branch" =~ ^([0-9]+)[-_] ]]; then
        PR="${BASH_REMATCH[1]}"
    else
        echo "❌ PR number not provided and cannot infer from branch '$branch'"
        echo "   Usage: $0 <pr-number>"
        exit 1
    fi
fi

############################################
# 3. Show PR info and collect diff
############################################
echo "🔍 Showing PR $PR..."
gh pr view "$PR"
read -rp "Press Enter to fetch the diff and open it in \$EDITOR... " _

echo "📥 Fetching diff for PR $PR into $DIFF_FILE"
if ! gh pr diff "$PR" > "$DIFF_FILE"; then
    echo "❌ Failed to fetch diff"
    exit 1
fi

editor_cmd=${EDITOR:-vi}
echo "✏️  Opening $DIFF_FILE with editor: $editor_cmd"
if ! eval "$editor_cmd \"$DIFF_FILE\""; then
    echo "❌ Failed to open editor ($editor_cmd)"
    exit 1
fi

############################################
# 4. Commit ID
############################################
if ! commit_id=$(gh pr view "$PR" --json headRefOid --jq '.headRefOid' 2>/dev/null); then
    commit_id=$(git rev-parse HEAD)
fi

############################################
# 5. Parse diff
############################################
current_file=""
new_line_in_hunk=0
last_real_line=0
position=0
last_position=0
in_hunk=false
# keep array initialized so set -u doesn't treat it as unset
declare -a comments=()

while IFS='' read -r line || [[ -n "$line" ]]; do

    # File header: +++ b/<file>
    if [[ "$line" =~ ^\+\+\+\ b/ ]]; then
        current_file="${line#+++ b/}"
        in_hunk=false
        new_line_in_hunk=0
        last_real_line=0
        position=0
        last_position=0
        continue
    fi

    # Hunk header: @@ -a,b +c,d @@
    if [[ "$line" =~ ^@@ ]]; then
        in_hunk=true
        new_line_in_hunk=$(echo "$line" \
            | sed -E 's/^@@ -[0-9]+(,[0-9]+)? \+([0-9]+).*/\2/')
        new_line_in_hunk=$((new_line_in_hunk - 1))
        continue
    fi

    # Ignore everything until first file header is seen
    if [[ -z "$current_file" ]]; then
        continue
    fi

    first_char="${line:0:1}"

    # Track absolute position within the diff for this file
    if [[ "$first_char" == "+" || "$first_char" == "-" || "$first_char" == " " ]]; then
        position=$((position + 1))
        last_position=$position
    fi

    # Only added/context lines increase new file position
    if [[ "$first_char" == "+" || "$first_char" == " " ]]; then
        new_line_in_hunk=$((new_line_in_hunk + 1))
        last_real_line=$new_line_in_hunk
    fi

    # Detect GH inline comment marker
    if [[ "$line" == "$PREFIX"* ]]; then

        # skip if file has no hunks (binary or nondiff file)
        if ! $in_hunk; then
            continue
        fi

        comment="${line#"$PREFIX"}"
        comment="${comment#"${comment%%[![:space:]]*}"}"  # trim leading whitespace
        comments+=("$current_file$SEP$last_real_line$SEP$last_position$SEP$comment")
    fi

done < "$DIFF_FILE"

############################################
# 6. Show collected comments
############################################
echo "📦 Repo: $OWNER/$REPO"
echo "🔢 PR:   $PR"
echo "💬 Found ${#comments[@]} comment(s):"
echo

if [[ ${#comments[@]} -gt 0 ]]; then
    for c in "${comments[@]}"; do
        IFS="$SEP" read -r f l p b <<< "$c"
        printf "  → %s:%s (pos %s)   %s\n" "$f" "$l" "$p" "$b"
    done

    echo
    read -rp "Post these comments to GitHub? (y/N) " ans
    [[ "$ans" == "y" ]] || echo "Skipping inline comments."
else
    echo "  (no inline comments found)"
    ans="n"
fi

############################################
# 7. Post comments
############################################
if [[ "$ans" == "y" ]]; then
    for c in "${comments[@]}"; do
        IFS="$SEP" read -r f l p b <<< "$c"
        echo "→ Posting $f:$l"

        if [[ -z "$p" || "$p" == "0" ]]; then
            echo "WARNING: Skipping $f:$l (no diff position detected)"
            continue
        fi

        if output=$(gh api \
            --silent \
            "repos/$OWNER/$REPO/pulls/$PR/comments" \
            -f body="$b" \
            -f commit_id="$commit_id" \
            -f path="$f" \
            -F position="$p" 2>&1); then
            echo "   ✅ Created comment"
        else
            echo "   ❌ Failed to create comment: $output"
        fi
    done
fi

echo
echo "📝 Launching gh pr review $PR..."
gh pr review "$PR"

echo "✅ Done."
