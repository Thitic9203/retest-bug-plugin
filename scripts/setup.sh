#!/bin/bash
# One-time setup: install git hooks for auto cache sync
# รันครั้งเดียวหลัง clone — หลังจากนั้น git pull จะ sync cache ให้อัตโนมัติ

set -e

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
if [ -z "$REPO_ROOT" ]; then
  echo "Error: ต้องรันจาก repo directory"
  exit 1
fi

cd "$REPO_ROOT"

# Install post-merge hook
HOOK_SRC="scripts/hooks/post-merge"
HOOK_DST=".git/hooks/post-merge"

if [ ! -f "$HOOK_SRC" ]; then
  echo "Error: $HOOK_SRC not found"
  exit 1
fi

# Don't overwrite existing hook — append or skip
if [ -f "$HOOK_DST" ]; then
  if grep -q "retest-bug" "$HOOK_DST"; then
    echo "post-merge hook already installed — skipping"
  else
    echo "Warning: .git/hooks/post-merge already exists (from another tool)"
    echo "Manual setup needed — copy content from $HOOK_SRC"
    exit 1
  fi
else
  cp "$HOOK_SRC" "$HOOK_DST"
  chmod +x "$HOOK_DST"
  echo "post-merge hook installed"
fi

echo ""
echo "Setup complete! git pull จะ sync plugin cache ให้อัตโนมัติ"
echo "ไม่ต้อง reinstall plugin ใน Claude Code อีกต่อไป"
