# Progress

Commit Message: normalize convention markdown whitespace

Features (Planned):
- TBD

Features (Done):
- Normalized `.iron/conventions/*.md` line endings and trailing whitespace so repos that mirror the template can pass `git diff --check` without breaking exact-copy checks.

Features (In Progress):
- TBD

Notes:
- Last change/problem: Exact-mirrored convention files carried old trailing whitespace into target repo diffs.
- Fix attempts: Removed CRLF/trailing spaces from the template convention Markdown and revalidated `git diff --check`.
