# =========================================
# | proto conventions Smoke Tests                   |
# |---------------------------------------|
# | Minimal compile/runtime checks.       |
# =========================================

import std/[unittest, strutils]
import ../src/proto_conventions/interfaces/backend/core

suite "proto conventions scaffold":
  test "backend description":
    let c = initBackend("proto conventions")
    check describeBackend(c).contains("proto conventions")

