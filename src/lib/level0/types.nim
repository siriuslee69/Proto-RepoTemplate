# ==================================================
# | Level0 Types                                   |
# |------------------------------------------------|
# | Shared sample types used by the parser stack.  |
# ==================================================

type
  TypeA* = uint8
  TypeB* = uint16

  TypeC* = object
    value*: uint32
    vectors*: seq[(TypeA, TypeB)]
