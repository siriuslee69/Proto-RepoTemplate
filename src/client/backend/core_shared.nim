# ==================================================
# | proto conventions Backend Core                  |
# |-------------------------------------------------|
# | Shared backend state used by the sample UIs.    |
# ==================================================

import ../../../.iron/meta/metaPragmas
import ../../protocols/level0/types
import ../../protocols/level2/otherFunction

template backendMemory() {.pragma:
    input({trusted}),
    role({memory}),
    risk(low),
    speed(fast),
    issues(@[(name: "backend-context", id: 1'u64)]),
    tag({other})
  .}

template backendActor() {.pragma:
    input({trusted}),
    role({actor}),
    risk(low),
    speed(fast),
    issues(@[(name: "backend-context", id: 2'u64)]),
    tag({other})
  .}

type
  BackendContext* {.backendMemory.} = object
    name*: string
    status*: string
    sampleCount*: int
    sampleValue*: uint32
    sampleVectors*: seq[(TypeA, TypeB)]
    profileId*: string
    profileName*: string
    profileRole*: string
    profileBadge*: string
    workspaceName*: string
    focusId*: string

proc initBackend*(n: string): BackendContext {.backendActor.} =
  ## n: application name to tag the backend context.
  var
    t0: TypeC
  t0 = otherFunction(3'u8)
  result.name = n
  result.status = "ready"
  result.sampleCount = t0.vectors.len
  result.sampleValue = t0.value
  result.sampleVectors = t0.vectors
  result.profileId = "ops-047"
  result.profileName = "Mina Ortega"
  result.profileRole = "Operations Lead"
  result.profileBadge = "MO"
  result.workspaceName = "Northline Dispatch"
  result.focusId = "BR-29"
  if t0.vectors.len > 0:
    result.focusId = "BR-" & $int(t0.vectors[t0.vectors.len - 1][0])

proc describeBackend*(c: BackendContext): string {.backendActor.} =
  ## c: backend context to describe state for logs.
  result = "Backend " & c.name & " is " & c.status & " with " & $c.sampleCount & " sample vectors"
