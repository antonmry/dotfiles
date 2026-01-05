#!/bin/bash
# Sync Claude Code skills and config to Codex
#
# Why this script exists:
# TOML doesn't allow duplicate keys, so dotter can't map one source file
# to multiple destinations. We use this post-deploy hook to copy shared
# config from Claude to Codex after dotter deploys.

mkdir -p ~/.codex/skills/dotfiles
mkdir -p ~/.codex/skills/neovim

cp ~/.claude/skills/dotfiles/SKILL.md ~/.codex/skills/dotfiles/SKILL.md
cp ~/.claude/skills/neovim/SKILL.md ~/.codex/skills/neovim/SKILL.md
cp ~/.claude/CLAUDE.md ~/.codex/AGENTS.md
