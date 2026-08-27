# ==================================================
# | Level2 otherFunction                           |
# |------------------------------------------------|
# | Combines parser output into a sample snapshot. |
# ==================================================

import ../level0/types
import ../level1/parser

proc otherFunction*(a: TypeA): TypeC =
  let
    p = parserProc(a + 5'u8)
    q = parserProc(a)
  var i = 0
  result.value = uint32(p.len)
  result.vectors = @[]
  while i < p.len:
    let
      t0 = TypeA((int(p[i][0]) + int(q[i][0])) mod 256)
      t1 = p[i][1] + q[i][1]
    result.vectors.add((t0, t1))
    i.inc()

when isMainModule:
  echo $otherFunction(10)
