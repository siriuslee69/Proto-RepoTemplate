# =========================================
# | proto conventions CLI Entrypoint               |
# |---------------------------------------|
# | Prints backend status for automation. |
# =========================================

import interfaces/backend/core

when isMainModule:
  let c = initBackend("proto conventions")
  echo describeBackend(c)
