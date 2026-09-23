# Progress

Commit Message: Take every generic task from the shared Nimble-Tasks repo

Features (Planned):
- TBD

Features (Done):
- Shared Otter-readable code, stage, and evaluation pragmas.
- `evaluation/tests`, `evaluation/benchmarks`, and `evaluation/statistics` layout.
- Generic nimble tasks come from the Nimble-Tasks submodule (git flow, submodules, frontends, evaluation).

Features (In Progress):
- None

Notes:
- Last problem encountered: the frontend tasks pointed at `src/client/…` after the files had moved to `src/proto/client/…`, and the frontends imported a module that no longer existed.
- Fix: Nimble-Tasks also looks inside `src/<package>/`; the frontends `import proto`. runCli, buildCli, buildTui, buildOwl (in the nix shell) and test all pass.
