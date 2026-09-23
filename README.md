## Proto-RepoTemplate
This repo is meant as a template for other repos.

## Quick Start Guide


## Repo Role
- Give humans and agents one place to read the baseline project conventions.
- Keep repository architecture patterns consistent across Mimir, Hugin, Eris, Fjord, and future repos.
- Provide publish-safe templates for `README.md`, `CONTRIBUTING.md`,
  and `agents/PROGRESS.md` (pragmas come from the shared `Rune-Pragmas` repo).
- Ship a small Nim scaffold that demonstrates the intended protocol and client layout.

## Commands

Almost every task comes from the shared
[Nimble-Tasks](https://github.com/siriuslee69/Nimble-Tasks) repo, included at
the end of `proto.nimble`. The same names work in every repo:

```
task                              what it does
────────────────────────────────  ─────────────────────────────────────────
nimble test                       every evaluation/tests/**/test*.nim
nimble runBenchmarks              every evaluation/benchmarks/**/bench*.nim
nimble runStatistics              every evaluation/statistics/**/stat*.nim
nimble runCli      / buildCli     command line
nimble runTui      / buildTui     terminal (illwill)
nimble runOwl      / buildOwl     GTK4 (owlkettle) - inside
                                  nix-shell nix/owlkettle-shell.nix
nimble runWebui    / buildWebui   nim-webui window
nimble runServer   / buildServer  server
nimble buildAll                   every frontend that exists
nimble autopush                   commit with agents/PROGRESS.md's message, push
nimble switch                     nightly <-> main
nimble applyNightly               main moves forward to nightly
nimble mainToNightlySnap          nightly gets main's files, keeps its history
nimble updateSubmodules           every submodule -> newest main commit
nimble sharedTasks                the full list
```

This repo's own tasks: `nimble smoke`, `nimble testMetaPragmas`.

Each shared task prints where it came from before it runs:

```
🌿 (｡•̀ᴗ-)✧ Calling outsourced nimble task `runCli` from Nimble-Tasks submodule (../Nimble-Tasks)
```

A new repo keeps the include block at the end of its `.nimble` file and adds
the submodule:

```sh
git submodule add https://github.com/siriuslee69/Nimble-Tasks.git submodules/Nimble-Tasks
```

## License
This repo uses the Unlicense. See `UNLICENSE`.
