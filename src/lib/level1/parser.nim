# ==================================================
# | Level1 Parser                                  |
# |------------------------------------------------|
# | Operates on TypeA and returns TypeB.           |
# ==================================================

import ../level0/types

proc helper1(x: TypeA): TypeB =
    var 
        calc1: uint16 = 8
        calc2: uint16
    for i in 0..8:
        calc2 = calc1 + x
    result = calc2

proc helper2(x: TypeA): TypeB =
    echo $x
    let
        p: uint8 = x xor 2
        q: uint8 = x - 2
        r: uint8 = x * 4
    result = cast[uint16](p * q + r)

proc parserProc*(a: TypeA): seq[(TypeA, TypeB)] =
    let
        p: uint16 = helper1(a)
        q: uint16 = helper2(5)
    var
        i = 0
        T: seq[(TypeA, TypeB)] = @[]
    while i < 10: 
        let 
            t0: TypeA = cast[uint8](q + p + i.uint16())
            t1: TypeB = a + 1
        T.add((t0, t1))
        i.inc()
    result = T
    

when isMainModule: #Quick functionality test, should be inside each .nim file in level1 and below (except the types.nim and the bundled exporter exporter)
    echo $parserProc(10)