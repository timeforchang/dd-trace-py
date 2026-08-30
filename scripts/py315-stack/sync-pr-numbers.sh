#!/usr/bin/env bash
# Query GitHub for PR numbers by head branch and refresh pr-numbers.env + bodies.
# Preserves manually set PRn= values; only fills empty slots from GitHub.
#
# Usage:
#   ./sync-pr-numbers.sh              # sync empty slots from GitHub
#   ./sync-pr-numbers.sh PR1=19267    # set PR1 then sync + regenerate
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$DIR/pr-numbers.env"

declare -A EXISTING=()
if [[ -f "$ENV_FILE" ]]; then
  while IFS='=' read -r key value; do
    [[ "$key" =~ ^PR[0-9]+$ ]] || continue
    EXISTING["$key"]="$value"
  done < <(grep -E '^PR[0-9]+=' "$ENV_FILE" || true)
fi

for arg in "$@"; do
  if [[ "$arg" =~ ^(PR[0-9]+)=(.*)$ ]]; then
    EXISTING["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
  else
    echo "Usage: $0 [PRn=number ...]" >&2
    exit 1
  fi
done

declare -a BRANCHES=(
  "PR1|vlad/315-peripheral-compat"
  "PR2|vlad/ddtracepy-315-profiling-native"
  "PR3|vlad/ddtracepy-315-profiling-collectors"
  "PR4|vlad/ddtracepy-315-profiling-asyncio-monitoring"
  "PR5|vlad/315-profiling-test-install-subdir"
  "PR6|vlad/315-profiling-dev-tooling"
)

lookup_pr() {
  local branch=$1
  gh pr list --head "$branch" --state all --json number --jq 'sort_by(.number) | last | .number // empty' 2>/dev/null || true
}

TMP="$(mktemp)"
{
  echo "# Profiling stack (6 PRs) on #19861. ./sync-pr-numbers.sh [PRn=num ...] then regenerates bodies."
  echo "# Floor (not a slot): 19861 vlad/py315-manylinux-wheels"
  echo "# Not this stack: 17849 wrap, 19254 official-support, riot 19880–19906"
} > "$TMP"

for entry in "${BRANCHES[@]}"; do
  key="${entry%%|*}"
  branch="${entry#*|}"
  num="${EXISTING[$key]:-}"

  if [[ -z "$num" ]]; then
    num="$(lookup_pr "$branch")"
  fi

  echo "${key}=${num}" >> "$TMP"
  if [[ -n "$num" ]]; then
    printf '  %s=%s  (%s)\n' "$key" "$num" "$branch"
  else
    printf '  %s=       (%s) — no PR yet\n' "$key" "$branch"
  fi
done

mv "$TMP" "$ENV_FILE"
echo ""
echo "Wrote ${ENV_FILE}"
"$DIR/generate-pr-urls.sh"
