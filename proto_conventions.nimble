import std/[os, strutils]

version       = "0.1.0"
author        = "siriuslee69"
description   = "Shared conventions, templates, and example scaffolds for split Nim repos"
license       = "Unlicense"
srcDir        = "src"

proc resolveProgressPath(): string =
  var
    ts: seq[string] = @[
      ".iron/PROGRESS.md",
      ".iron/progress.md"
    ]
  for t in ts:
    if fileExists(t):
      return t
  result = ts[0]

proc resolveWebUiEntryPath(): string =
  var
    ts: seq[string] = @[
      "src/client/frontend/webui/app.nim",
      "src/client/frontend/webui_ui/app.nim"
    ]
  for t in ts:
    if fileExists(t):
      return t
  result = ts[0]

task autopush, "Add, commit, and push with message from .iron/PROGRESS.md":
  var path = resolveProgressPath()
  var msg = ""
  if fileExists(path):
    var content = readFile(path)
    for line in content.splitLines:
      if line.startsWith("Commit Message:"):
        msg = line["Commit Message:".len .. ^1].strip()
        break
  if msg.len == 0:
    msg = "No specific commit message given."
  exec "git add -A ."
  exec "git commit -m \"" & msg & "\""
  exec "git push"

task find, "Use local clones for submodules in parent folder":
  let modulesPath = ".gitmodules"
  if not fileExists(modulesPath):
    echo "No .gitmodules found."
  else:
    let root = parentDir(getCurrentDir())
    var current = ""
    for line in readFile(modulesPath).splitLines:
      let s = line.strip()
      if s.startsWith("[submodule"):
        let start = s.find('"')
        let stop = s.rfind('"')
        if start >= 0 and stop > start:
          current = s[start + 1 .. stop - 1]
      elif current.len > 0 and s.startsWith("path"):
        let parts = s.split("=", maxsplit = 1)
        if parts.len == 2:
          let subPath = parts[1].strip()
          let tail = splitPath(subPath).tail
          let localDir = joinPath(root, tail)
          if dirExists(localDir):
            let localUrl = localDir.replace('\\', '/')
            exec "git config -f .gitmodules submodule." & current & ".url " & localUrl
            exec "git config submodule." & current & ".url " & localUrl
    exec "git submodule sync --recursive"

requires "nim >= 1.6.0", "owlkettle >= 3.0.0", "illwill >= 0.4.0", "webui >= 2.5.0"

task buildDesktop, "Build the GTK4 desktop app":
  exec "nim c -d:release src/client/frontend/owlkettle_ui/app.nim"

task runDesktop, "Run the GTK4 desktop app":
  exec "nim c -r src/client/frontend/owlkettle_ui/app.nim"

task runCli, "Run the CLI entrypoint":
  exec "nim c -r src/client/frontend/cli/app_cli.nim"

task runTui, "Run the TUI entrypoint":
  exec "nim c -r src/client/frontend/illwill_tui/app_tui.nim"

task buildWebUi, "Build the WebUI entrypoint":
  exec "nim c --nimcache:build/nimcache_webui " & resolveWebUiEntryPath()

task runWebUi, "Build and run the WebUI entrypoint":
  exec "nim c -r --nimcache:build/nimcache_webui_run " & resolveWebUiEntryPath()

task test, "Run unit tests":
  exec "nim c -r tests/test_smoke.nim"

task smoke, "Run smoke tests":
  exec "nim c -r tests/test_smoke.nim"

task testMetaPragmas, "Compile and run the pragma smoke test":
  exec "nim c -r tests/test_meta_pragmas.nim"
