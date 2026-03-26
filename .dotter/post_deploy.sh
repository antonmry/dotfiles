#!/bin/bash
# Sync Claude Code skills and config to Codex
#
# Why this script exists:
# TOML doesn't allow duplicate keys, so dotter can't map one source file
# to multiple destinations. We use this post-deploy hook to copy shared
# config from Claude to Codex after dotter deploys.

for skill_dir in ~/.claude/skills/*/; do
  skill=$(basename "$skill_dir")
  mkdir -p ~/.codex/skills/"$skill"
  cp "$skill_dir"SKILL.md ~/.codex/skills/"$skill"/SKILL.md
done

cp ~/.claude/CLAUDE.md ~/.codex/AGENTS.md
