# ==================================================
# | Level1 Parser                                  |
# |------------------------------------------------|
# | Builds sample pairs from the shared types.     |
# ==================================================

import ../level0/types

proc helper1(a: TypeA): TypeB =
  result = TypeB(a) + 8'u16

proc helper2(a: TypeA): TypeB =
  let
    p = a xor 2'u8
    q = a + 4'u8
  result = TypeB(p) + TypeB(q)

proc parserProc*(a: TypeA): seq[(TypeA, TypeB)] =
  let
    p = helper1(a)
    q = helper2(a)
  var i = 0
  result = @[]
  while i < 10:
    let
      t0 = TypeA((int(a) + i) mod 256)
      t1 = p + q + TypeB(i)
    result.add((t0, t1))
    i.inc()

when isMainModule:
  echo $parserProc(10)
