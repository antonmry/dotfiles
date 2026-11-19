#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: codex.sh [TITLE]\n       codex.sh --resume\n\n'
  printf 'Start Happier Codex in the current terminal and directory.\n'
  printf 'Without TITLE, prompt for one; Enter uses the repo or folder name.\n'
  printf 'With --resume (-r), list local Codex sessions for this folder and join one.\n'
}

resume=false
case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  -r|--resume) resume=true ;;
esac
if [ "$#" -gt 1 ]; then
  usage >&2
  exit 1
fi

for dependency in happier jq; do
  if ! command -v "$dependency" >/dev/null 2>&1; then
    printf 'Required command not found: %s\n' "$dependency" >&2
    exit 1
  fi
done

session_dir=$(pwd -P)
happier_dir=${HAPPIER_HOME_DIR:-$HOME/.happier}
case "$happier_dir" in
  '~') happier_dir=$HOME ;;
  '~/'*) happier_dir="$HOME/${happier_dir:2}" ;;
esac

resume_session() {
  local machine_id response cursor='' next_cursor entry id title state selection selected_id
  local -a args session_rows=()

  if [ ! -t 0 ]; then
    printf 'Resume needs an interactive terminal.\n' >&2
    return 1
  fi
  if ! machine_id=$(jq -r '.activeServerId as $server | .machineIdByServerId[$server] // empty' "$happier_dir/settings.json"); then
    printf 'Could not read the local Happier machine ID.\n' >&2
    return 1
  fi
  if [ -z "$machine_id" ]; then
    printf 'No local Happier machine ID is configured.\n' >&2
    return 1
  fi

  while :; do
    args=(session list --limit 100 --json)
    if [ -n "$cursor" ]; then
      args+=(--cursor "$cursor")
    fi
    if ! response=$(happier "${args[@]}"); then
      printf 'Could not list Happier sessions: %s\n' "$(jq -r '.error.message // empty' <<< "$response" 2>/dev/null || printf '%s' "$response")" >&2
      return 1
    fi
    if ! jq -e '.ok == true and (.data.sessions | type == "array")' <<< "$response" >/dev/null; then
      printf 'Happier returned an unexpected session list.\n' >&2
      return 1
    fi
    while IFS= read -r entry; do
      session_rows+=("$entry")
    done < <(jq -r --arg path "$session_dir" --arg machine "$machine_id" '
      .data.sessions[]
      | select(.path == $path and .machineId == $machine and .agentId == "codex")
      | [.id, ((.title // "Untitled") | gsub("[\t\r\n]"; " ")), (if .active then "active" else "stopped" end)]
      | @tsv
    ' <<< "$response")
    next_cursor=$(jq -r '.data.nextCursor // empty' <<< "$response")
    if [ -z "$next_cursor" ]; then
      break
    fi
    if [ "$next_cursor" = "$cursor" ]; then
      printf 'Happier returned a repeated session cursor.\n' >&2
      return 1
    fi
    cursor=$next_cursor
  done

  if [ "${#session_rows[@]}" -eq 0 ]; then
    printf 'No local Codex sessions found for %s.\n' "$session_dir"
    return 0
  fi

  printf 'Codex sessions for %s:\n' "$session_dir"
  for ((i=0; i<${#session_rows[@]}; i++)); do
    IFS=$'\t' read -r id title state <<< "${session_rows[$i]}"
    printf '%2d) %-7s %s [%s]\n' "$((i+1))" "$state" "$title" "${id:0:8}"
  done
  while :; do
    read -r -p 'Session number (Enter to cancel): ' selection || return 1
    if [ -z "$selection" ]; then
      return 0
    fi
    if [[ "$selection" =~ ^[0-9]+$ ]] &&
       [ "$selection" -ge 1 ] 2>/dev/null &&
       [ "$selection" -le "${#session_rows[@]}" ] 2>/dev/null; then
      IFS=$'\t' read -r selected_id title state <<< "${session_rows[$((selection-1))]}"
      exec happier resume "$selected_id"
    fi
    printf 'Choose a number from 1 to %d, or Enter to cancel.\n' "${#session_rows[@]}"
  done
}

if [ "$resume" = true ]; then
  resume_session
  exit $?
fi

repo_dir=$(git rev-parse --show-toplevel 2>/dev/null || printf '%s' "$session_dir")
default_title=$(basename "$repo_dir")
default_title=${default_title:-Codex}
session_title=${1:-}
if [ "$#" -eq 0 ] && [ -t 0 ]; then
  read -r -p "Session title [$default_title]: " session_title || exit 1
fi
if [[ "$session_title" != *[![:space:]]* ]]; then
  session_title=$default_title
fi

lock_dir="$happier_dir/tmp/session-runner-locks"
launch_time_ms=$(($(date +%s) * 1000))

name_new_session() {
  local launch_pid=$1 title=$2 locks=$3 started_at=$4
  local attempt lock_file session_id rename_result
  for ((attempt=0; attempt<60; attempt++)); do
    if ! kill -0 "$launch_pid" 2>/dev/null; then
      return 1
    fi
    for lock_file in "$locks"/*.json; do
      [ -f "$lock_file" ] || continue
      session_id=$(jq -r --argjson pid "$launch_pid" --argjson started "$started_at" '
        select(.pid == $pid and .acquiredAtMs >= $started) | .sessionId // empty
      ' "$lock_file" 2>/dev/null) || continue
      if [ -n "$session_id" ]; then
        if rename_result=$(happier session set-title "$session_id" "$title" --json 2>/dev/null) &&
          printf '%s' "$rename_result" | jq -e '.ok == true' >/dev/null 2>&1; then
          return 0
        fi
      fi
    done
    sleep 1
  done
  printf 'Could not set Happier session title: %s\n' "$title" >&2
  return 1
}

# The shell keeps its PID across exec, so the lock identifies this launch.
name_new_session "$$" "$session_title" "$lock_dir" "$launch_time_ms" &

exec happier codex --happy-terminal-mode plain --permission-mode default
