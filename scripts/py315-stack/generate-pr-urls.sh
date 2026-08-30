#!/usr/bin/env bash
# Generate GitHub compare URLs + PR bodies for the live profiling-315 stack.
# EMU blocks `gh pr create`; use open-all-draft-prs.sh or compare URLs in DRAFT_PRS.md.
# Does not emit official-support or empty historical slots.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

ENV_FILE="$(dirname "$0")/pr-numbers.env"
# shellcheck disable=SC1090
source "$ENV_FILE"

STACK_MAX=6
REPO="DataDog/dd-trace-py"
BASE_URL="https://github.com/${REPO}"

pr_num() {
  local n=$1
  local var="PR${n}"
  echo "${!var:-}"
}

pr_url() {
  local n=$1
  local num
  num="$(pr_num "$n")"
  if [[ -n "$num" ]]; then
    echo "${BASE_URL}/pull/${num}"
  else
    echo ""
  fi
}

nav_line() {
  local idx=$1
  local prev_n=$((idx - 1))
  local next_n=$((idx + 1))
  local prev next prev_num next_num prev_url next_url

  if [[ $prev_n -ge 1 ]]; then
    prev_num="$(pr_num "$prev_n")"
    prev_url="$(pr_url "$prev_n")"
    if [[ -n "$prev_num" && -n "$prev_url" ]]; then
      prev="[#${prev_num}](${prev_url})"
    else
      prev="_#${prev_n} (pending)_"
    fi
  else
    prev="[#19861](${BASE_URL}/pull/19861)"
  fi

  if [[ $next_n -le $STACK_MAX ]]; then
    next_num="$(pr_num "$next_n")"
    next_url="$(pr_url "$next_n")"
    if [[ -n "$next_num" && -n "$next_url" ]]; then
      next="[#${next_num}](${next_url})"
    else
      next="_#${next_n} (pending)_"
    fi
  else
    next="—"
  fi

  echo "**prev:** ${prev} | **next:** ${next}"
}

urlencode() {
  python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.stdin.read()))'
}

write_pr_entry() {
  local idx=$1
  local total=$2
  local head=$3
  local base=$4
  local title=$5
  local summary=$6
  local action_note=${7:-}
  local test_plan=${8:-"- [ ] CI green on this branch
- [ ] Stack merges cleanly into the next PR's base branch"}

  local nav body_file body_encoded title_encoded compare_url existing pr_var existing_num

  nav="$(nav_line "$idx")"
  body_file="${OUT_DIR}/$(printf '%02d' "$idx")-${head//\//-}.md"

  cat > "$body_file" <<EOF
${nav}

## Summary

${summary}
${action_note}

## Test plan

${test_plan}

EOF

  body_encoded="$(cat "$body_file" | urlencode)"
  title_encoded="$(printf '%s' "$title" | urlencode)"
  compare_url="${BASE_URL}/compare/${base}...${head}?expand=1&title=${title_encoded}&body=${body_encoded}&draft=1"

  existing="$(pr_url "$idx")"
  pr_var="PR${idx}"
  existing_num="${!pr_var:-}"
  {
    echo "## ${idx}/${total} — \`${head}\` → \`${base}\`"
    echo ""
    if [[ -n "$existing" && -n "$existing_num" ]]; then
      echo "**Existing PR:** [#${existing_num}](${existing}) — set base to \`${base}\`, mark draft, paste body from [\`pr-bodies/$(basename "$body_file")\`](pr-bodies/$(basename "$body_file"))."
    else
      echo "**Open draft:** [Create PR on GitHub](${compare_url})"
    fi
    echo ""
    echo "${nav}"
    echo ""
    echo "<details><summary>PR body (copy)</summary>"
    echo ""
    cat "$body_file"
    echo ""
    echo "</details>"
    echo ""
  } >> "$INDEX"

  printf '%s\n' "$compare_url" > "${OUT_DIR}/$(printf '%02d' "$idx")-compare.url"
}

# idx|head|base|title|summary|action_note (optional, use · for empty)
ENTRIES=(
  "1|vlad/315-peripheral-compat|vlad/py315-manylinux-wheels|chore(profiling-315): logging version warning and FunctionStore restore|Peripheral compat on #19861: version warning + FunctionStore restore_all unwrap.|·"
  "2|vlad/ddtracepy-315-profiling-native|vlad/315-peripheral-compat|chore(profiling-315): native py3.15 ABI and test install subdirs|Native C++/Rust 3.15 ABI. INSTALL_SUBDIR extract is #19947, not this layer.|·"
  "3|vlad/ddtracepy-315-profiling-collectors|vlad/ddtracepy-315-profiling-native|chore(profiling-315): collectors and py3.15 CI matrix|Collector updates and 3.15 riot/CI matrix. Does not lift requires-python.|·"
  "4|vlad/ddtracepy-315-profiling-asyncio-monitoring|vlad/ddtracepy-315-profiling-collectors|refactor(profiling-315): sys.monitoring asyncio path for py3.15|Replace bytecode wrapping with sys.monitoring in _asyncio.py when wrapping is unavailable.|·"
  "5|vlad/315-profiling-test-install-subdir|vlad/ddtracepy-315-profiling-asyncio-monitoring|chore(profiling-315): install 3.15 gtest in test/py315|Install 3.15 gtest under test/py315. Does not declare official 3.15 support.|·"
  "6|vlad/315-profiling-dev-tooling|vlad/315-profiling-test-install-subdir|docs(profiling-315): py3.15 dev tooling and CPython upgrade runbook|Bring-up scripts, compatibility baselines, Echion migration runbook. Docs/scripts only; does not declare official 3.15 support.|·"
)

OUT_DIR="$(dirname "$0")/pr-bodies"
mkdir -p "$OUT_DIR"
INDEX="$(dirname "$0")/DRAFT_PRS.md"

{
  echo "# Python 3.15 profiling stack — draft PRs (6)"
  echo ""
  echo "Live chain: #19861 ← #19267 ← #19269 ← #19270 ← #19272 ← #19947 ← #19273."
  echo "Do **not** open \`vlad/315-official-support\` or declare official 3.15 support from these scripts."
  echo ""
  echo "EMU blocks \`gh pr create\` / \`gh pr edit\`. Run [\`sync-pr-numbers.sh\`](sync-pr-numbers.sh) then [\`open-all-draft-prs.sh\`](open-all-draft-prs.sh)."
  echo "Set numbers: \`./sync-pr-numbers.sh PR1=19267 PR2=19269 ...\` (preserves existing, fills gaps from GitHub)."
  echo ""
} > "$INDEX"

for entry in "${ENTRIES[@]}"; do
  IFS='|' read -r idx head base title summary action_note <<< "$entry"
  if [[ "$action_note" == "·" ]]; then action_note=""; else
    action_note=$'\n\n'"${action_note}"
  fi

  test_plan="- [ ] CI green on this branch
- [ ] Stack merges cleanly into the next PR's base branch"
  if [[ "$idx" == "6" ]]; then
    test_plan="- [ ] \`scripts/run-profiling-tests --check-only\` on a version that has the required venvs
- [ ] Docs build / link check"
  fi

  write_pr_entry "$idx" "$STACK_MAX" "$head" "$base" "$title" "$summary" "$action_note" "$test_plan"
done

echo "Wrote ${INDEX} and ${OUT_DIR}/*.md"
