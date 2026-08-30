# Python 3.15 profiling stack (6 PRs)

**Vintage:** Sun 2026-08-30 07:02 EDT (−0400). Live `gh pr view` tips. #19267 base is #19861 (`vlad/py315-manylinux-wheels`), **not** `main`. Not merge-ready.

Live chain: **#19861 ← #19267 ← #19269 ← #19270 ← #19272 ← #19947 ← #19273**.

[#19910](https://github.com/DataDog/dd-trace-py/pull/19910) **merged** on `main` (`3e4b91aba1`). This stack was **not** rebased onto it — a profiling wheel does **not** contain the wrap lift. [#17849](https://github.com/DataDog/dd-trace-py/pull/17849) is on `main` and is not this stack. Do not open `vlad/315-official-support`.

## Merge order (bottom → top)

| # | PR | Branch | Base branch | Tip SHA (origin) |
|---|-----|--------|-------------|------------------|
| — | [#19861](https://github.com/DataDog/dd-trace-py/pull/19861) | `vlad/py315-manylinux-wheels` | `vlad/py315-lib-injection-ssi` | `cac61cabb5` |
| 1 | [#19267](https://github.com/DataDog/dd-trace-py/pull/19267) | `vlad/315-peripheral-compat` | `vlad/py315-manylinux-wheels` | `6daa0b84e0` |
| 2 | [#19269](https://github.com/DataDog/dd-trace-py/pull/19269) | `vlad/ddtracepy-315-profiling-native` | `vlad/315-peripheral-compat` | `082d4d36c9` |
| 3 | [#19270](https://github.com/DataDog/dd-trace-py/pull/19270) | `vlad/ddtracepy-315-profiling-collectors` | `vlad/ddtracepy-315-profiling-native` | `7f36ee7766` |
| 4 | [#19272](https://github.com/DataDog/dd-trace-py/pull/19272) | `vlad/ddtracepy-315-profiling-asyncio-monitoring` | `vlad/ddtracepy-315-profiling-collectors` | `b19564006f` |
| 5 | [#19947](https://github.com/DataDog/dd-trace-py/pull/19947) | `vlad/315-profiling-test-install-subdir` | `vlad/ddtracepy-315-profiling-asyncio-monitoring` | `0c96a8f880` |
| 6 | [#19273](https://github.com/DataDog/dd-trace-py/pull/19273) | `vlad/315-profiling-dev-tooling` | `vlad/315-profiling-test-install-subdir` | this branch tip |

**Closed (absorbed earlier):** [#19268](https://github.com/DataDog/dd-trace-py/pull/19268) → #19269 · [#19271](https://github.com/DataDog/dd-trace-py/pull/19271) → #19270

**Not in this stack:** wrap #19910 (on main); riot #19880–#19906; IMAGE_TAG [#19936](https://github.com/DataDog/dd-trace-py/pull/19936); closed [#19254](https://github.com/DataDog/dd-trace-py/pull/19254).

## Layer table

| Layer | Meaning | Which PR |
| --- | --- | --- |
| Compiled into artifact | Native C++/Rust 3.15 ABI, cmake tests | #19269 |
| Test install layout | 3.15 gtest under `test/py315` | #19947 |
| Armed at runtime | Collectors + setup.py native compile + riot/CI matrix | #19270 |
| Observable in product/Python | sys.monitoring asyncio path; `wrap()` stays below 3.15 | #19272 |
| Docs / bring-up | Runbook, verify script, this file | #19273 |
| Peripheral (logging / FunctionStore) | Version warning + restore_all unwrap | #19267 |

#19272 is **not** the wrap lift. Do not attach DoE/AB to #19273.

## Validation legs (314 vs 315)

Version is the knob; wheel SHA stays fixed. Do not start until the human says **authed**.

- **Wrap-free DoE** (alloc isolated / full-stack / bytearray): profiling SHA. Runtime/asyncio: **#19272** `b19564006f`. Natives-only: **#19270** `7f36ee7766`.
- **Wrap-sensitive TD** (`ai_gateway`): needs #19910 **in the wheel** (main, or rebase).
- Attach results to **#19269 / #19270 / #19272**.
- prof-correctness 3.15 is **S3-wheel only** (`install.sh`). Needs #19936 + pc #191 + #19269+#19270. Residual: `requires-python >=3.9,<3.15`, no `--ignore-requires-python`. Do not merge #19880 to unblock it.

Sign-off: prof-correctness → DoE alloc isolated → full-stack → `rapid_python_http_smoke_test` TD → `ai_gateway` TD (after wrap is in the wheel) → `ds-metrics-workers` temporal soak.
