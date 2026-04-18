# ==================================================
# | proto conventions Nim WebUI Frontend            |
# |-------------------------------------------------|
# | Hosts the local web folder and snapshot shell.  |
# ==================================================

import std/[json, os]
import webui
import ../../backend/core_webui

const
  AppName = "proto conventions"

proc resolveWebRoot(): string =
  var
    t0: string = splitFile(currentSourcePath()).dir
  result = joinPath(t0, "web")

template buildFallbackSnapshotJson(): string =
  var
    t0: BackendContext = initBackend(AppName)
    t1: string = describeBackend(t0)
    t2: JsonNode = %*{
      "appName": AppName,
      "status": t0.status,
      "sampleCount": t0.sampleCount,
      "summary": t1,
      "pages": [
        {
          "id": "overview",
          "label": "Overview",
          "caption": "core",
          "items": [
            {"label": "name", "value": t0.name, "meta": "app", "tone": "active"},
            {"label": "status", "value": t0.status, "meta": "link", "tone": "glue"},
            {"label": "vectors", "value": $t0.sampleCount, "meta": "count", "tone": "tiny"}
          ]
        },
        {
          "id": "snapshot",
          "label": "Snapshot",
          "caption": "bridge",
          "items": [
            {"label": "source", "value": "fallback", "meta": "local", "tone": "recommendation"},
            {"label": "summary", "value": t1, "meta": "cache", "tone": "active"}
          ]
        }
      ],
      "focus": [
        {"label": "bridge", "value": "fallback", "meta": "local", "tone": "recommendation"},
        {"label": "summary", "value": t1, "meta": "core", "tone": "active"}
      ],
      "statusLine": [
        {"label": "link", "value": "local"},
        {"label": "mode", "value": "cached"},
        {"label": "samples", "value": $t0.sampleCount}
      ]
    }
  $t2

proc protoGetSnapshotCb(): string =
  var
    t0: string = buildFallbackSnapshotJson()
  when compiles(buildWebUiSnapshot(initBackend(AppName))):
    t0 = buildWebUiSnapshot(initBackend(AppName))
  result = t0

proc runApp() =
  var
    t0: Window
    t1: string
    t2: bool = false
  t1 = resolveWebRoot()
  if not dirExists(t1):
    raise newException(IOError, "Missing web root: " & t1)
  t0 = newWindow()
  t0.setSize(1440, 920)
  discard t0.`rootFolder=`(t1)
  t0.bind("protoGetSnapshot", protoGetSnapshotCb)
  t2 = t0.show("index.html")
  if not t2:
    raise newException(IOError, "Could not open index.html from: " & t1)
  wait()
  clean()

when isMainModule:
  runApp()
