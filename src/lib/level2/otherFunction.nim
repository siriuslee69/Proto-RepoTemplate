# ==================================================
# | Level2 otherFunction                                  |
# |------------------------------------------------|
# | Operates on TypeA and returns mainly TypeC.    |
# ==================================================

import ../level0/types
import ../level1/parser

proc otherFunction(a: TypeA): TypeC =
    let 
        p = parserProc(a+5)
        q = parserProc(a)
    var
        i = 0
        l = p.len()
    while i < l:
        let 
            t0 = p[i][0] + q[i][0]
            t1 = p[i][1] + q[i][1]
        result.vectors.add((t0, t1))
        i.inc()

when isMainModule:
    echo $otherFunction(10)