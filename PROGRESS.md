# Progress

Commit Message: add the test pragmas, and point the tests at the meta file that is actually tracked.

Features (Planned):
- TBD

Features (Done):
- Added `testKind`, `covers`, and `pins` to `meta/metaPragmas.nim`, so a test says what it proves the same way a routine says what it is. Kinds: unit, edge case, benchmark, regression, bugfix, integration, fuzz, smoke, property, other.
- Added `sanitizer` and `configurator` to `MetaRole`, and the scalar forms of `role` and `input` beside the set forms, so the template is the superset every child repo copies rather than a subset they each patch.
- Documented in `agents/CONVENTIONS.md` that a child repo copies this file rather than writing its own, because Otter reads these names to draw a repo's statistics.
- Fixed every `metaPragmas` import: they pointed at `.iron/meta/`, which this repo does not have and does not track, so both test suites failed to compile in a fresh clone.
- Normalized `.iron/conventions/*.md` line endings and trailing whitespace so repos that mirror the template can pass `git diff --check` without breaking exact-copy checks.

Features (In Progress):
- TBD

Notes:
- Last change/problem: every `import ../.iron/meta/metaPragmas` in `src/` and `tests/` pointed at a folder this repo neither has nor tracks. The tracked file is `meta/metaPragmas.nim`. `nimble test` and `nimble testMetaPragmas` both failed on a clean clone with `cannot open file`, which is a poor first impression from the repo whose job is to be copied.
- Fix attempts: pointed all four imports at `../meta/metaPragmas`. Both suites pass.
