#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"
DEPTH="${1:-3}"
EXCLUDE='Pods|Carthage|DerivedData|build|.git'
if command -v tree >/dev/null 2>&1; then
  tree -L "$DEPTH" -I "$EXCLUDE" > Docs/project_tree.md
else
  find . -maxdepth "$DEPTH" -path './.git' -prune -o -print | sed 's|^\./||' > Docs/project_tree.md
fi
git add Docs/project_tree.md
git commit -m "docs(tree): обновлён Docs/project_tree.md (depth=${DEPTH})" || true
