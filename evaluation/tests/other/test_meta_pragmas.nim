# =========================================
# | meta pragma Smoke Tests               |
# |--------------------------------------|
# | Direct checks for shared meta usage. |
# =========================================

import std/[strutils, unittest]
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

proc metaPragmaSmoke() {.
    testKind(tkSmoke),
    covers("trimMetaInput"),
    pins((name: "meta-pragma-smoke", id: 1'u64))
  .} =
  check trimMetaInput("  pragma smoke  ") == "pragma smoke"

suite "meta pragmas":
  # {.testKind: tkSmoke.}
  test "compile and run without extra repo edits":
    metaPragmaSmoke()
