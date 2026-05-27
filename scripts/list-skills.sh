#!/usr/bin/env bash
set -euo pipefail

# List every SKILL.md in the repo with its bucket and name.

REPO="$(cd "$(dirname "$0")/.." && pwd)"

cd "$REPO"
find . -name SKILL.md -not -path '*/node_modules/*' | sed 's|^\./||' | sort
