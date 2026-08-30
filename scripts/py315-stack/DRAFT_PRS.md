# Python 3.15 profiling stack — draft PRs (6)

Live chain: #19861 ← #19267 ← #19269 ← #19270 ← #19272 ← #19947 ← #19273.
Do **not** open `vlad/315-official-support` or declare official 3.15 support from these scripts.

EMU blocks `gh pr create` / `gh pr edit`. Run [`sync-pr-numbers.sh`](sync-pr-numbers.sh) then [`open-all-draft-prs.sh`](open-all-draft-prs.sh).
Set numbers: `./sync-pr-numbers.sh PR1=19267 PR2=19269 ...` (preserves existing, fills gaps from GitHub).

## 1/6 — `vlad/315-peripheral-compat` → `vlad/py315-manylinux-wheels`

**Existing PR:** [#19267](https://github.com/DataDog/dd-trace-py/pull/19267) — set base to `vlad/py315-manylinux-wheels`, mark draft, paste body from [`pr-bodies/01-vlad-315-peripheral-compat.md`](pr-bodies/01-vlad-315-peripheral-compat.md).

**prev:** [#19861](https://github.com/DataDog/dd-trace-py/pull/19861) | **next:** [#19269](https://github.com/DataDog/dd-trace-py/pull/19269)

<details><summary>PR body (copy)</summary>

**prev:** [#19861](https://github.com/DataDog/dd-trace-py/pull/19861) | **next:** [#19269](https://github.com/DataDog/dd-trace-py/pull/19269)

## Summary

Peripheral compat on #19861: version warning + FunctionStore restore_all unwrap.


## Test plan

- [ ] CI green on this branch
- [ ] Stack merges cleanly into the next PR's base branch


</details>

## 2/6 — `vlad/ddtracepy-315-profiling-native` → `vlad/315-peripheral-compat`

**Existing PR:** [#19269](https://github.com/DataDog/dd-trace-py/pull/19269) — set base to `vlad/315-peripheral-compat`, mark draft, paste body from [`pr-bodies/02-vlad-ddtracepy-315-profiling-native.md`](pr-bodies/02-vlad-ddtracepy-315-profiling-native.md).

**prev:** [#19267](https://github.com/DataDog/dd-trace-py/pull/19267) | **next:** [#19270](https://github.com/DataDog/dd-trace-py/pull/19270)

<details><summary>PR body (copy)</summary>

**prev:** [#19267](https://github.com/DataDog/dd-trace-py/pull/19267) | **next:** [#19270](https://github.com/DataDog/dd-trace-py/pull/19270)

## Summary

Native C++/Rust 3.15 ABI. INSTALL_SUBDIR extract is #19947, not this layer.


## Test plan

- [ ] CI green on this branch
- [ ] Stack merges cleanly into the next PR's base branch


</details>

## 3/6 — `vlad/ddtracepy-315-profiling-collectors` → `vlad/ddtracepy-315-profiling-native`

**Existing PR:** [#19270](https://github.com/DataDog/dd-trace-py/pull/19270) — set base to `vlad/ddtracepy-315-profiling-native`, mark draft, paste body from [`pr-bodies/03-vlad-ddtracepy-315-profiling-collectors.md`](pr-bodies/03-vlad-ddtracepy-315-profiling-collectors.md).

**prev:** [#19269](https://github.com/DataDog/dd-trace-py/pull/19269) | **next:** [#19272](https://github.com/DataDog/dd-trace-py/pull/19272)

<details><summary>PR body (copy)</summary>

**prev:** [#19269](https://github.com/DataDog/dd-trace-py/pull/19269) | **next:** [#19272](https://github.com/DataDog/dd-trace-py/pull/19272)

## Summary

Collector updates and 3.15 riot/CI matrix. Does not lift requires-python.


## Test plan

- [ ] CI green on this branch
- [ ] Stack merges cleanly into the next PR's base branch


</details>

## 4/6 — `vlad/ddtracepy-315-profiling-asyncio-monitoring` → `vlad/ddtracepy-315-profiling-collectors`

**Existing PR:** [#19272](https://github.com/DataDog/dd-trace-py/pull/19272) — set base to `vlad/ddtracepy-315-profiling-collectors`, mark draft, paste body from [`pr-bodies/04-vlad-ddtracepy-315-profiling-asyncio-monitoring.md`](pr-bodies/04-vlad-ddtracepy-315-profiling-asyncio-monitoring.md).

**prev:** [#19270](https://github.com/DataDog/dd-trace-py/pull/19270) | **next:** [#19947](https://github.com/DataDog/dd-trace-py/pull/19947)

<details><summary>PR body (copy)</summary>

**prev:** [#19270](https://github.com/DataDog/dd-trace-py/pull/19270) | **next:** [#19947](https://github.com/DataDog/dd-trace-py/pull/19947)

## Summary

Replace bytecode wrapping with sys.monitoring in _asyncio.py when wrapping is unavailable.


## Test plan

- [ ] CI green on this branch
- [ ] Stack merges cleanly into the next PR's base branch


</details>

## 5/6 — `vlad/315-profiling-test-install-subdir` → `vlad/ddtracepy-315-profiling-asyncio-monitoring`

**Existing PR:** [#19947](https://github.com/DataDog/dd-trace-py/pull/19947) — set base to `vlad/ddtracepy-315-profiling-asyncio-monitoring`, mark draft, paste body from [`pr-bodies/05-vlad-315-profiling-test-install-subdir.md`](pr-bodies/05-vlad-315-profiling-test-install-subdir.md).

**prev:** [#19272](https://github.com/DataDog/dd-trace-py/pull/19272) | **next:** [#19273](https://github.com/DataDog/dd-trace-py/pull/19273)

<details><summary>PR body (copy)</summary>

**prev:** [#19272](https://github.com/DataDog/dd-trace-py/pull/19272) | **next:** [#19273](https://github.com/DataDog/dd-trace-py/pull/19273)

## Summary

Install 3.15 gtest under test/py315. Does not declare official 3.15 support.


## Test plan

- [ ] CI green on this branch
- [ ] Stack merges cleanly into the next PR's base branch


</details>

## 6/6 — `vlad/315-profiling-dev-tooling` → `vlad/315-profiling-test-install-subdir`

**Existing PR:** [#19273](https://github.com/DataDog/dd-trace-py/pull/19273) — set base to `vlad/315-profiling-test-install-subdir`, mark draft, paste body from [`pr-bodies/06-vlad-315-profiling-dev-tooling.md`](pr-bodies/06-vlad-315-profiling-dev-tooling.md).

**prev:** [#19947](https://github.com/DataDog/dd-trace-py/pull/19947) | **next:** —

<details><summary>PR body (copy)</summary>

**prev:** [#19947](https://github.com/DataDog/dd-trace-py/pull/19947) | **next:** —

## Summary

Bring-up scripts, compatibility baselines, Echion migration runbook. Docs/scripts only; does not declare official 3.15 support.


## Test plan

- [ ] `scripts/run-profiling-tests --check-only` on a version that has the required venvs
- [ ] Docs build / link check


</details>

