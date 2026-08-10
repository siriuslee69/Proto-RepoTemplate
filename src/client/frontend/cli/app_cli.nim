# =========================================
# | proto conventions CLI Entrypoint               |
# |---------------------------------------|
# | Prints backend status for automation. |
# =========================================

import ../../../proto_conventions

when isMainModule:
  var
    c: BackendContext = initBackend("proto conventions")
  echo describeBackend(c)
