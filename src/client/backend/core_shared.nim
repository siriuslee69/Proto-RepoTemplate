# ==================================================
# | proto conventions Backend Core                  |
# |-------------------------------------------------|
# | Shared backend state used by the sample UIs.    |
# ==================================================

import lib/level2/otherFunction

type
  BackendContext* = object
    name*: string
    status*: string
    sampleCount*: int

proc initBackend*(n: string): BackendContext =
  ## n: application name to tag the backend context.
  let sample = otherFunction(3'u8)
  result.name = n
  result.status = "ready"
  result.sampleCount = sample.vectors.len

proc describeBackend*(c: BackendContext): string =
  ## c: backend context to describe state for logs.
  result = "Backend " & c.name & " is " & c.status & " with " & $c.sampleCount & " sample vectors"
