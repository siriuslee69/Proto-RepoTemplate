# =========================================
# | proto conventions Smoke Tests          |
# |---------------------------------------|
# | Minimal compile/runtime checks.       |
# =========================================

import std/[strutils, unittest]
import ../src/proto_conventions
import ../.iron/meta/metaPragmas

proc trimMetaInput(s: string): string {.
    input({user}),
    role({helper}),
    risk(low),
    speed(fast),
    issues(@[(name: "template-smoke", id: 1'u64)]),
    tag({other})
  .} =
  result = s.strip()

suite "proto conventions scaffold":
  test "backend description includes the app name":
    var
      c: BackendContext = initBackend("proto conventions")
    check describeBackend(c).contains("proto conventions")

  test "meta pragmas compile out of the box":
    check trimMetaInput("  pragma smoke  ") == "pragma smoke"
