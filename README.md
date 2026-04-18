# proto-conventions

Please read `.iron/conventions/CONVENTIONS.md` first.
Shared conventions, templates, and example scaffolding for the split Nim repos in this workspace.

## Repo Role
- Give humans and agents one place to read the baseline project conventions.
- Keep repository architecture patterns consistent across Mimir, Hugin, Eris, Fjord, and future repos.
- Provide publish-safe templates for `README.md`, `CONTRIBUTING.md`, and `.iron/` repo metadata.
- Ship a small Nim scaffold that demonstrates the intended `src/protocols` and `src/client` layout.

## What to read first
- `.iron/conventions/CONVENTIONS.md`
  - coding, layout, documentation, and publish hygiene conventions.
- `.iron/conventions/PROJECTS.md`
  - split-repo layout and nimble task expectations.
- `.iron/conventions/UI.md`
  - UI defaults for WebUI-first frontend work.
- `CONTRIBUTING.md`
  - architecture documentation checklist and review expectations.
- `proto_conventions.nimble`
  - shared developer tasks for smoke tests and local runs.

## Repo Layout
- `src/protocols/`
  - sample protocol/library modules grouped by dependency level.
- `src/proto_conventions.nim`
  - public package surface used by the smoke test and frontend samples.
- `src/client/backend/`
  - shared backend helpers for client-facing entrypoints.
- `src/client/frontend/cli/`
  - CLI sample entrypoint.
- `src/client/frontend/illwill_tui/`
  - illwill terminal sample entrypoint.
- `src/client/frontend/owlkettle_ui/`
  - GTK4/OwlKettle desktop sample entrypoint.
- `src/client/frontend/webui/`
  - WebUI sample entrypoint for the browser-style desktop shell.
- `tests/test_smoke.nim`
  - minimal coverage for the public package surface.
- `.iron/`
  - tracked templates for conventions, progress logging, and iron config scaffolding.

## Expected Repo Documentation
Every production repo should have:
- `README.md`
  - explain the repo boundary, main state, orchestrators, and examples.
- `CONTRIBUTING.md`
  - explain how to change the repo safely, which functions matter most, and what tests to run.
- `.iron/PROGRESS.md`
  - work log and commit message source for `autopush`.
- `.iron/.local.config.toml.template`
  - tracked, publish-safe template for the local machine config.
- `.iron/.local.config.toml`
  - machine-local config copied from the template and ignored by git.

## Commands
- `nimble test`
  - run the smoke test suite.
- `nimble runCli`
  - compile and run the CLI entrypoint.
- `nimble runTui`
  - compile and run the illwill TUI entrypoint.
- `nimble buildDesktop`
  - compile the OwlKettle desktop example.
- `nimble runDesktop`
  - compile and run the OwlKettle desktop example.
- `nimble buildWebUi`
  - compile the WebUI example entrypoint.
- `nimble runWebUi`
  - compile and run the WebUI example entrypoint.

## Notes
- `proto-conventions` is a reference repo, not a production service.
- If a new split repo appears, update this repo with any new architecture patterns worth standardizing.
- Keep tracked files free of absolute local paths, generated binaries, and editor-specific state.

## License
This repo uses the Unlicense. See `UNLICENSE`.
