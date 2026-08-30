#!/usr/bin/env bash
# Historical 14-PR rebuild (gab multiplexer → official-support) is disabled.
# It must not recreate vlad/315-official-support or declare official 3.15 support.
set -euo pipefail

echo "rebuild-stack.sh is historical and refuses to run." >&2
echo "Live stack: #19861 ← #19267 ← #19269 ← #19270 ← #19272 ← #19947 ← #19273" >&2
echo "See scripts/py315-stack/PROFILING_STACK.md" >&2
exit 1
