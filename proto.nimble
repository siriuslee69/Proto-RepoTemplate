version       = "0.1.0"
author        = "siriuslee69"
description   = "Shared conventions, templates, and example scaffolds for split Nim repos"
license       = "Unlicense"
srcDir        = "src"

requires "nim >= 1.6.0", "owlkettle >= 3.0.0", "illwill >= 0.4.0", "webui >= 2.5.0"

## ---------------------------------------------------------------------------
## This repo's own tasks. Everything else - autopush, switch, applyNightly,
## updateSubmodules, runWebui/runCli/runTui/runOwl/runServer and their build*
## twins, test, runBenchmarks, … - comes from Nimble-Tasks (included below).
## `nimble sharedTasks` lists them.
## ---------------------------------------------------------------------------

task testMetaPragmas, "Compile and run the pragma smoke test":
  mkDir("build")
  exec "nim c -o:build/test_meta_pragmas -r evaluation/tests/other/test_meta_pragmas.nim"

task smoke, "Run smoke tests":
  mkDir("build")
  exec "nim c -o:build/test_smoke -r evaluation/tests/other/test_smoke.nim"

## Shared tasks: the sibling clone wins, so an edit there reaches this repo
## at once; the submodule is what a fresh clone elsewhere falls back on.
when fileExists(thisDir() & "/../Nimble-Tasks/src/nimbleTasks.nims"):
  include "../Nimble-Tasks/src/nimbleTasks.nims"
elif fileExists(thisDir() & "/submodules/Nimble-Tasks/src/nimbleTasks.nims"):
  include "submodules/Nimble-Tasks/src/nimbleTasks.nims"
else:
  {.error: "Nimble-Tasks not found: git submodule update --init submodules/Nimble-Tasks".}
