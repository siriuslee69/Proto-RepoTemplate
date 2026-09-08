# =========================================
# | meta pragma Smoke Tests               |
# |--------------------------------------|
# | Direct checks for shared meta usage. |
# =========================================

import std/[strutils, unittest]
import protoPragmas

proc trimMetaInput(s: string): string {.
    input({user}),
    role({helper}),
    risk(low),
    speed(fast),
    issues(@[(name: "template-smoke", id: 1'u64)]),
    metaTags({tagOther}),
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
