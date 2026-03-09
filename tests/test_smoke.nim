# =========================================
# | proto conventions Smoke Tests          |
# |---------------------------------------|
# | Minimal compile/runtime checks.       |
# =========================================

import std/[strutils, unittest]
import ../src/proto_conventions

suite "proto conventions scaffold":
  test "backend description includes the app name":
    let c = initBackend("proto conventions")
    check describeBackend(c).contains("proto conventions")
