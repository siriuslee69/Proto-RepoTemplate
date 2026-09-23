# =========================================
# | proto conventions Smoke Tests          |
# |---------------------------------------|
# | Minimal compile/runtime checks.       |
# =========================================

import std/[strutils, unittest]
import proto
import runePragmas

proc trimMetaInput(s: string): string {.
    input({user}),
    role({helper}),
    risk(rkLow),
    speed(spFast),
    issues(@[(name: "template-smoke", id: 1'u64)]),
    tag("other"),
    stage(stDone)
  .} =
  result = s.strip()

suite "proto conventions scaffold":
  # {.testKind: tkSmoke.}
  test "backend description includes the app name":
    var
      c: BackendContext = initBackend("proto conventions")
    check describeBackend(c).contains("proto conventions")

  # {.testKind: tkSmoke.}
  test "meta pragmas compile out of the box":
    check trimMetaInput("  pragma smoke  ") == "pragma smoke"
