# ==================================================
# | proto conventions WebUI Backend Export          |
# |-------------------------------------------------|
# | Web snapshot export for browser frontends.      |
# ==================================================

import std/json
import ../../../.iron/meta/metaPragmas
import ../../protocols/level0/types
import core

export core

const
  SnapshotGeneratedAt = "2026-04-19T09:30:00Z"
  SnapshotTimezone = "Europe/Berlin"

template webuiHelper() {.pragma:
    input({trusted}),
    role({helper}),
    risk(low),
    speed(fast),
    issues(@[(name: "webui-snapshot", id: 3'u64)]),
    tag({other})
  .}

template webuiActor() {.pragma:
    input({trusted}),
    role({actor}),
    risk(low),
    speed(fast),
    issues(@[(name: "webui-snapshot", id: 4'u64)]),
    tag({other})
  .}

proc sampleVector(c: BackendContext, i: int): (TypeA, TypeB) {.webuiHelper.} =
  ## c: backend context with deterministic sample vectors.
  ## i: vector index to read from the sample window.
  var
    t0: int = 0
  result = (0'u8, 0'u16)
  if c.sampleVectors.len == 0:
    return
  t0 = i mod c.sampleVectors.len
  result = c.sampleVectors[t0]

proc sampleKey(c: BackendContext, i: int): int {.webuiHelper.} =
  ## c: backend context with deterministic sample vectors.
  ## i: vector index to read from the sample window.
  var
    t0: (TypeA, TypeB)
  t0 = sampleVector(c, i)
  result = int(t0[0])

proc sampleMagnitude(c: BackendContext, i: int): int {.webuiHelper.} =
  ## c: backend context with deterministic sample vectors.
  ## i: vector index to read from the sample window.
  var
    t0: (TypeA, TypeB)
  t0 = sampleVector(c, i)
  result = int(t0[1])

proc buildSparkValues(c: BackendContext, s: int, l: int, b: int): JsonNode {.webuiHelper.} =
  ## c: backend context used to derive sparkline values.
  ## s: starting index inside the deterministic sample window.
  ## l: number of points to emit.
  ## b: baseline value subtracted from each sample magnitude.
  var
    t0: JsonNode = newJArray()
    i: int = 0
    t1: int = 0
  while i < l:
    t1 = sampleMagnitude(c, s + i) - b
    t0.add(%t1)
    i.inc()
  result = t0

proc buildAppSection(c: BackendContext): JsonNode {.webuiHelper.} =
  ## c: backend context to surface as snapshot metadata.
  var
    t0: JsonNode = %*{
      "name": c.name,
      "status": c.status,
      "environment": "example",
      "generatedAt": SnapshotGeneratedAt,
      "timezone": SnapshotTimezone,
      "workspace": c.workspaceName,
      "sampleCount": c.sampleCount,
      "sampleValue": int(c.sampleValue)
    }
  result = t0

proc buildAuthSection(c: BackendContext): JsonNode {.webuiHelper.} =
  ## c: backend context to surface as auth and profile data.
  var
    t0: JsonNode
    t1: JsonNode = newJArray()
    t2: int = max(c.sampleCount - 3, 0)
    t3: int = sampleKey(c, 0) mod 4
  t0 = %*{
    "activeTab": "profile",
    "tabs": [
      {"id": "profile", "label": "Profile", "active": true},
      {"id": "security", "label": "Security", "active": false, "badge": "1"},
      {"id": "recover", "label": "Recover", "active": false}
    ],
    "profile": {
      "id": c.profileId,
      "badge": c.profileBadge,
      "name": c.profileName,
      "role": c.profileRole,
      "workspace": c.workspaceName,
      "presence": "online",
      "email": "mina.ortega@example.internal",
      "lastLogin": "2026-04-19T08:42:00Z",
      "authMethod": "hardware-key",
      "sessionLabel": "Desk-A3"
    }
  }
  t1.add(%*{"label": "Queues", "value": $t2})
  t1.add(%*{"label": "Window", "value": $int(c.sampleValue) & "/10"})
  t1.add(%*{"label": "Flags", "value": $t3})
  t0["profile"]["quickStats"] = t1
  result = t0

proc buildTopMenuSection(c: BackendContext): JsonNode {.webuiHelper.} =
  ## c: backend context to surface as top menu and navigation data.
  var
    t0: JsonNode = %*{
      "search": {
        "placeholder": "Search batches, queues, operators",
        "value": c.focusId & " manual review"
      }
    }
    t1: JsonNode = newJArray()
    t2: JsonNode = newJArray()
  t1.add(%*{"id": "workspace", "label": c.workspaceName, "kind": "context", "active": true})
  t1.add(%*{"id": "window", "label": "Last 30m", "kind": "window"})
  t1.add(%*{"id": "filters", "label": "Priority mixed", "kind": "filter"})
  t1.add(%*{"id": "sync", "label": "Auto-sync", "kind": "toggle", "active": true})
  t2.add(%*{"id": "overview", "label": "Overview", "active": true})
  t2.add(%*{"id": "activity", "label": "Activity", "badge": "4", "active": false})
  t2.add(%*{"id": "queue", "label": "Queue", "badge": $max(c.sampleCount - 3, 0), "active": false})
  t2.add(%*{"id": "focus", "label": "Focus", "badge": c.focusId, "active": false})
  t0["menuButtons"] = t1
  t0["nav"] = t2
  result = t0

proc buildOverviewSection(c: BackendContext): JsonNode {.webuiHelper.} =
  ## c: backend context to surface as overview metric cards.
  var
    t0: JsonNode = newJObject()
    t1: JsonNode = newJArray()
    t2: JsonNode
    t3: int = max(c.sampleCount - 3, 0)
    t4: int = sampleMagnitude(c, 4)
    t5: int = sampleMagnitude(c, 0) + sampleMagnitude(c, 1)
    t6: int = sampleKey(c, 0) mod 4
  t2 = %*{
    "id": "queues",
    "label": "Open queues",
    "value": $t3,
    "delta": "+2 since 08:00",
    "trend": "up",
    "tone": "active"
  }
  t2["spark"] = buildSparkValues(c, 0, 6, 50)
  t1.add(t2)
  t2 = %*{
    "id": "review",
    "label": "Median review",
    "value": $t4 & " sec",
    "delta": "-4 sec vs prior run",
    "trend": "down",
    "tone": "steady"
  }
  t2["spark"] = buildSparkValues(c, 1, 6, 52)
  t1.add(t2)
  t2 = %*{
    "id": "resolved",
    "label": "Resolved today",
    "value": $t5,
    "delta": "+11 from prior cycle",
    "trend": "up",
    "tone": "active"
  }
  t2["spark"] = buildSparkValues(c, 2, 6, 48)
  t1.add(t2)
  t2 = %*{
    "id": "flags",
    "label": "Escalations",
    "value": $t6,
    "delta": "-1 cleared by rules",
    "trend": "down",
    "tone": "warn"
  }
  t2["spark"] = buildSparkValues(c, 3, 6, 56)
  t1.add(t2)
  t0["cards"] = t1
  result = t0

proc buildActivitySection(c: BackendContext): JsonNode {.webuiHelper.} =
  ## c: backend context to surface as recent activity items.
  var
    t0: JsonNode = newJObject()
    t1: JsonNode = newJArray()
  t1.add(%*{
    "id": "act-" & $sampleKey(c, 0),
    "title": "Policy pack BR-" & $sampleKey(c, 0) & " re-ranked",
    "summary": "Rules Engine moved " & $(sampleMagnitude(c, 0) - 50) & " items into manual review.",
    "time": "2m",
    "actor": "Rules Engine",
    "lane": "policy",
    "tone": "warn"
  })
  t1.add(%*{
    "id": "act-" & $sampleKey(c, 2),
    "title": "Settlement batch BR-" & $sampleKey(c, 2) & " released",
    "summary": "Queue Worker cleared " & $(sampleMagnitude(c, 2) - 50) & " ledger checks without retries.",
    "time": "8m",
    "actor": "Queue Worker",
    "lane": "settlement",
    "tone": "active"
  })
  t1.add(%*{
    "id": "act-" & $sampleKey(c, 4),
    "title": "Auth replay BR-" & $sampleKey(c, 4) & " verified",
    "summary": "Auth Monitor matched " & $(sampleMagnitude(c, 4) - 50) & " session events to the current operator.",
    "time": "14m",
    "actor": "Auth Monitor",
    "lane": "auth",
    "tone": "steady"
  })
  t1.add(%*{
    "id": "act-" & $sampleKey(c, 6),
    "title": "Escalation BR-" & $sampleKey(c, 6) & " assigned",
    "summary": c.profileName & " took ownership of " & $(sampleMagnitude(c, 6) - 50) & " pending documents.",
    "time": "22m",
    "actor": "Desk Lead",
    "lane": "ops",
    "tone": "active"
  })
  t0["items"] = t1
  result = t0

proc buildQueueSection(c: BackendContext): JsonNode {.webuiHelper.} =
  ## c: backend context to surface as queue list data.
  var
    t0: JsonNode = newJObject()
    t1: JsonNode = newJArray()
  t1.add(%*{
    "id": "Q-" & $sampleMagnitude(c, 5),
    "label": "Daily settlement",
    "owner": "Rules Engine",
    "size": $(sampleMagnitude(c, 5) - 60),
    "eta": "04m",
    "state": "manual-check",
    "tone": "active"
  })
  t1.add(%*{
    "id": "Q-" & $sampleMagnitude(c, 6),
    "label": "Profile sync",
    "owner": "Auth Monitor",
    "size": $(sampleMagnitude(c, 6) - 60),
    "eta": "06m",
    "state": "queued",
    "tone": "steady"
  })
  t1.add(%*{
    "id": "Q-" & $sampleMagnitude(c, 7),
    "label": "Exception replay",
    "owner": "Desk Lead",
    "size": $(sampleMagnitude(c, 7) - 60),
    "eta": "11m",
    "state": "blocked",
    "tone": "warn"
  })
  t1.add(%*{
    "id": "Q-" & $sampleMagnitude(c, 8),
    "label": "Recovery audit",
    "owner": c.profileName,
    "size": $(sampleMagnitude(c, 8) - 60),
    "eta": "14m",
    "state": "ready",
    "tone": "active"
  })
  t0["items"] = t1
  result = t0

proc buildFocusDetail(c: BackendContext): JsonNode {.webuiHelper.} =
  ## c: backend context to surface as the right panel focus detail.
  var
    t0: JsonNode = %*{
      "id": c.focusId,
      "title": "Manual approval band",
      "stage": "signature-review",
      "owner": c.profileName,
      "workspace": c.workspaceName,
      "summary": "Batch " & c.focusId & " is held because the recommendation spread climbed from " &
        $sampleMagnitude(c, 0) & " to " & $sampleMagnitude(c, 9) & " across the deterministic sample window."
    }
    t1: JsonNode = newJArray()
    t2: JsonNode = newJArray()
    t3: JsonNode = newJArray()
    t4: int = sampleMagnitude(c, 9) - sampleMagnitude(c, 0)
  t1.add(%*{"label": "Items", "value": $c.sampleCount})
  t1.add(%*{"label": "Spread", "value": $t4})
  t1.add(%*{"label": "Confidence", "value": "93%"})
  t1.add(%*{"label": "Window", "value": "09:00-09:30"})
  t2.add(%*{"label": "Auth context confirmed", "done": true})
  t2.add(%*{"label": "Queue ownership locked", "done": true})
  t2.add(%*{"label": "Operator sign-off pending", "done": false})
  t3.add(%*{"time": "09:08", "text": "Score band widened after auth replay."})
  t3.add(%*{"time": "09:16", "text": "Northline dispatch requested same-window approval."})
  t0["stats"] = t1
  t0["checklist"] = t2
  t0["notes"] = t3
  result = t0

proc buildBottomStatus(c: BackendContext): JsonNode {.webuiHelper.} =
  ## c: backend context to surface as bottom status items.
  var
    t0: JsonNode = newJObject()
    t1: JsonNode = newJArray()
  t1.add(%*{"id": "sync", "label": "Realtime", "value": "synced", "tone": "active"})
  t1.add(%*{"id": "vectors", "label": "Vectors", "value": $c.sampleCount & " loaded", "tone": "steady"})
  t1.add(%*{"id": "reviewClock", "label": "Review clock", "value": $sampleMagnitude(c, 4) & " sec", "tone": "steady"})
  t1.add(%*{"id": "operator", "label": "Operator", "value": c.profileName, "tone": "active"})
  t0["items"] = t1
  result = t0

proc buildWebUiSnapshot*(c: BackendContext): string {.webuiActor.} =
  ## c: backend context to transform into a full WebUI snapshot JSON payload.
  var
    t0: JsonNode = newJObject()
  t0["app"] = buildAppSection(c)
  t0["auth"] = buildAuthSection(c)
  t0["topMenu"] = buildTopMenuSection(c)
  t0["overview"] = buildOverviewSection(c)
  t0["activityFeed"] = buildActivitySection(c)
  t0["queue"] = buildQueueSection(c)
  t0["focusDetail"] = buildFocusDetail(c)
  t0["bottomStatus"] = buildBottomStatus(c)
  result = $t0
