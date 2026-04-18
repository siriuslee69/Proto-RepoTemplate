# =========================================
# | meta pragma Smoke Tests               |
# |--------------------------------------|
# | Direct checks for .iron/meta usage.  |
# =========================================

import std/[strutils, unittest]
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

suite "meta pragmas":
  test "compile and run without extra repo edits":
    check trimMetaInput("  pragma smoke  ") == "pragma smoke"
