#!/bin/bash
# One-command install: clone + symlink cache + set up hooks
# ผู้ใช้รันคำสั่งเดียว — หลังจากนั้น git pull = ได้ plugin ล่าสุดทันที
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/Thitic9203/retest-bug-plugin/main/scripts/install.sh | bash

set -e

REPO_URL="https://github.com/Thitic9203/retest-bug-plugin.git"
REPO_DIR="$HOME/.claude/plugins/src/retest-bug"
MARKETPLACE_NAME="retest-bug-dev"
PLUGIN_NAME="retest-bug"
CACHE_BASE="$HOME/.claude/plugins/cache/$MARKETPLACE_NAME/$PLUGIN_NAME"

echo "=== retest-bug plugin installer ==="
echo ""

# 1. Clone (or pull if already exists)
if [ -d "$REPO_DIR/.git" ]; then
  echo "[1/3] Repo exists — pulling latest..."
  git -C "$REPO_DIR" pull origin main --quiet
else
  echo "[1/3] Cloning repo..."
  mkdir -p "$(dirname "$REPO_DIR")"
  git clone "$REPO_URL" "$REPO_DIR" --quiet
fi

cd "$REPO_DIR"

# 2. Read version + create symlink in cache
VERSION=$(grep '"version"' .claude-plugin/plugin.json | head -1 | sed 's/.*"\([0-9]*\.[0-9]*\.[0-9]*\)".*/\1/')
if [ -z "$VERSION" ]; then
  echo "Error: cannot read version from plugin.json"
  exit 1
fi

echo "[2/3] Setting up cache symlink (v$VERSION)..."
mkdir -p "$CACHE_BASE"

# Remove old cache entries (copies or stale symlinks)
for OLD_ENTRY in "$CACHE_BASE"/*/; do
  [ -e "$OLD_ENTRY" ] || continue
  rm -rf "$OLD_ENTRY"
done

# Create symlink: cache/<version>/ → repo
ln -s "$REPO_DIR" "$CACHE_BASE/$VERSION"

# 3. Enable hooks from repo (so post-merge fires on git pull)
echo "[3/3] Enabling auto-update hooks..."
git config core.hooksPath scripts/hooks

echo ""
echo "=== Install complete ==="
echo "Plugin: $CACHE_BASE/$VERSION -> $REPO_DIR"
echo ""
echo "Update: cd $REPO_DIR && git pull"
echo "        (plugin cache updates automatically — no extra steps)"
