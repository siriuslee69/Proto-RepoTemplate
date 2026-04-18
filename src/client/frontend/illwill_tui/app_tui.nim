# =========================================
# | proto conventions TUI Entrypoint               |
# |---------------------------------------|
# | Minimal illwill-based terminal UI.    |
# =========================================

import illwill
import ../../../proto_conventions

const
  AppName = "proto conventions"

proc runApp() =
  var
    t0: TerminalBuffer
    t1: string
  t0 = newTerminalBuffer(80, 24)
  t0.clear()
  t1 = describeBackend(initBackend(AppName))
  t0.write(2, 1, AppName)
  t0.write(2, 3, t1)
  display(t0)
  discard getKey()

proc main() =
  illwillInit()
  hideCursor()
  try:
    runApp()
  finally:
    illwillDeinit()

when isMainModule:
  main()
