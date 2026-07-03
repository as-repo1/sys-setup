#!/usr/bin/env bash
# setup-git.sh — Configure git with user details

set -euo pipefail

echo "→ Configuring git..."

read -rp "  Git name  []: " GIT_NAME
GIT_NAME="${GIT_NAME:-}"
[[ -z "$GIT_NAME" ]] && { echo "  ✗ Git name cannot be empty."; exit 1; }

read -rp "  Git email []: " GIT_EMAIL
GIT_EMAIL="${GIT_EMAIL:-}"
[[ -z "$GIT_EMAIL" ]] && { echo "  ✗ Git email cannot be empty."; exit 1; }

git config --global user.name  "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
git config --global core.editor nvim
git config --global pull.rebase false

echo "  ✓ Git configured as '$GIT_NAME <$GIT_EMAIL>'"
