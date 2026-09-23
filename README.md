## Proto-RepoTemplate
This repo is meant as a template for other repos.

## Quick Start Guide


## Repo Role
- Give humans and agents one place to read the baseline project conventions.
- Keep repository architecture patterns consistent across Mimir, Hugin, Eris, Fjord, and future repos.
- Provide publish-safe templates for `README.md`, `CONTRIBUTING.md`,
  `agents/PROGRESS.md`, and `meta/metaPragmas.nim`.
- Ship a small Nim scaffold that demonstrates the intended protocol and client layout.

## Commands
- `nimble test`
  - run every Nim test below `evaluation/tests/`.
- `nimble runBenchmarks`
  - run every Nim benchmark below `evaluation/benchmarks/`.
- `nimble runStatistics`
  - run every Nim statistics entry below `evaluation/statistics/`.
- `nimble switch`
  - switch between the `nightly` and `main` branches.
- `nimble applyNightly`
- `nimble mainToNightlySnap`
  - fast-forward `main` to the tested `nightly` state and push it.
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

## License
This repo uses the Unlicense. See `UNLICENSE`.
