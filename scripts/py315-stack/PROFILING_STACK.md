# Python 3.15 profiling stack (6 PRs)

**Last updated:** 2026-08-29 — origin tips after the INSTALL_SUBDIR extract. #19267 base is #19861 (`vlad/py315-manylinux-wheels`), not `main`. Not merge-ready.

Import degrade for 3.15 is on `main` via [#19724](https://github.com/DataDog/dd-trace-py/pull/19724). [#17849](https://github.com/DataDog/dd-trace-py/pull/17849) (wrapping) stays on `main` and is not part of this stack. Official-support / riot PRs are separate. Do not open `vlad/315-official-support`.

Live chain: **#19861 ← #19267 ← #19269 ← #19270 ← #19272 ← #19947 ← #19273**.

## Merge order (bottom → top)

| # | PR | Branch | Base branch | Tip SHA (origin) |
|---|-----|--------|-------------|------------------|
| — | [#19861](https://github.com/DataDog/dd-trace-py/pull/19861) | `vlad/py315-manylinux-wheels` | `vlad/py315-lib-injection-ssi` | `cbe119a0e2` |
| 1 | [#19267](https://github.com/DataDog/dd-trace-py/pull/19267) | `vlad/315-peripheral-compat` | `vlad/py315-manylinux-wheels` | `6daa0b84e0` |
| 2 | [#19269](https://github.com/DataDog/dd-trace-py/pull/19269) | `vlad/ddtracepy-315-profiling-native` | `vlad/315-peripheral-compat` | `b63af74a55` |
| 3 | [#19270](https://github.com/DataDog/dd-trace-py/pull/19270) | `vlad/ddtracepy-315-profiling-collectors` | `vlad/ddtracepy-315-profiling-native` | `7f36ee7766` |
| 4 | [#19272](https://github.com/DataDog/dd-trace-py/pull/19272) | `vlad/ddtracepy-315-profiling-asyncio-monitoring` | `vlad/ddtracepy-315-profiling-collectors` | `a0853e62c1` |
| 5 | [#19947](https://github.com/DataDog/dd-trace-py/pull/19947) | `vlad/315-profiling-test-install-subdir` | `vlad/ddtracepy-315-profiling-asyncio-monitoring` | `0c96a8f880` |
| 6 | [#19273](https://github.com/DataDog/dd-trace-py/pull/19273) | `vlad/315-profiling-dev-tooling` | `vlad/315-profiling-test-install-subdir` | this branch tip |

**Closed (absorbed earlier):** [#19268](https://github.com/DataDog/dd-trace-py/pull/19268) → #19269 · [#19271](https://github.com/DataDog/dd-trace-py/pull/19271) → #19270

**Not in this stack:** [#19254](https://github.com/DataDog/dd-trace-py/pull/19254) official support (closed), riot #19880–#19906, wrap #17849.

## Layer table

| Layer | Meaning | Which PR |
| --- | --- | --- |
| Compiled into artifact | Native C++/Rust 3.15 ABI, cmake tests | #19269 |
| Test install layout | 3.15 gtest under `test/py315` | #19947 |
| Armed at runtime | Collectors + setup.py native compile + riot/CI matrix | #19270 |
| Observable in product/Python | sys.monitoring asyncio path (wrapping unavailable) | #19272 |
| Docs / bring-up | Runbook, verify script, this file | #19273 |
| Peripheral (logging / FunctionStore) | Version warning + restore_all unwrap | #19267 |

## Validation legs (314 vs 315)

1. **prof-correctness** downstream gate — same wheel SHA, paired 3.14/3.15 scenarios
2. **DoE alloc isolated** — `mem_only=true`, mixed domain
3. **DoE full-stack** — all default collectors
4. **Staging soaks** — `rapid_python_http_smoke_test` + `ai_gateway` TD, then `ds-metrics-workers` temporal windows

Trigger gate + DoE after first green **native + collectors/CI** wheel (#19270 tip).
