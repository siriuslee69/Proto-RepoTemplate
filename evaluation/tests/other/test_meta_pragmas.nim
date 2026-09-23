# =========================================
# | meta pragma Smoke Tests               |
# |--------------------------------------|
# | Direct checks for shared meta usage. |
# =========================================

import std/[macros, strutils, unittest]
import runePragmas

type
  AppState {.role: truthState, tag: "other",
    expectedCount: 1, lifeCycle: lcForever.} = object
    ## One of these, alive from the first line of the program to the last.
    n: int

  Frame {.role: preparedData, tag: "other",
    expectedCount: [0, 5000], lifeCycle: 100.} = object
    ## Up to five thousand at once, each alive about a tenth of a second.
    ## The two numbers together are what says this type is worth looking
    ## at and `AppState` is not.
    b: array[400, byte]

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

proc metaCountSmoke() {.testKind(tkSmoke), covers("expectedCount").} =
  ## A type's declared count and lifetime, read back while building.
  ## `expectedCount` and `lifeCycle` are one symbol each precisely so
  ## that this works; if either ever grows an overload, this stops
  ## compiling with "ambiguous identifier".
  static:
    doAssert AppState.hasCustomPragma(expectedCount)
    doAssert AppState.getCustomPragmaVal(lifeCycle) == lcForever
    doAssert Frame.getCustomPragmaVal(expectedCount) == [0, 5000]
    doAssert Frame.getCustomPragmaVal(lifeCycle) == 100
  check Frame.getCustomPragmaVal(expectedCount)[1] * sizeof(Frame) >= 2_000_000

suite "meta pragmas":
  # {.testKind: tkSmoke.}
  test "compile and run without extra repo edits":
    metaPragmaSmoke()

  # {.testKind: tkSmoke.}
  test "a type says how many of it there will be":
    metaCountSmoke()
