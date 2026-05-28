#!/bin/bash
# Post-clone setup: symlink cache + enable hooks
# สำหรับคนที่ clone repo มาเองแล้วต้องการ setup
# (ถ้าใช้ install.sh ไม่ต้องรัน script นี้)

set -e

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
if [ -z "$REPO_ROOT" ]; then
  echo "Error: run from inside the repo"
  exit 1
fi

cd "$REPO_ROOT"

MARKETPLACE_NAME="retest-bug-dev"
PLUGIN_NAME="retest-bug"
CACHE_BASE="$HOME/.claude/plugins/cache/$MARKETPLACE_NAME/$PLUGIN_NAME"

VERSION=$(grep '"version"' .claude-plugin/plugin.json | head -1 | sed 's/.*"\([0-9]*\.[0-9]*\.[0-9]*\)".*/\1/')
if [ -z "$VERSION" ]; then
  echo "Error: cannot read version"
  exit 1
fi

# Create symlink in cache
mkdir -p "$CACHE_BASE"
for OLD_ENTRY in "$CACHE_BASE"/*/; do
  [ -e "$OLD_ENTRY" ] || continue
  rm -rf "$OLD_ENTRY"
done
ln -s "$REPO_ROOT" "$CACHE_BASE/$VERSION"

# Enable hooks from repo
git config core.hooksPath scripts/hooks

echo "Setup complete (v$VERSION)"
echo "git pull = plugin auto-updated"
