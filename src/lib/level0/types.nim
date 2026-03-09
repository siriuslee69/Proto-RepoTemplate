# ==================================================
# | proto conventions Root Module                  |
# |------------------------------------------------|
# | Public exports for backend helpers.            |
# ==================================================

# Comment on what this type is used for
type 
    TypeA* = uint8 

# Comment on what this type is used for
    TypeB* = uint16 

# Comment on what this type is used for 
    TypeC* = object
        value*: uint32 #Comment on what this value does
        vectors*: seq[(TypeA, TypeB)] #Comment on what this weight does

