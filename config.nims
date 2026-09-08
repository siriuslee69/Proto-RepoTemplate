## The pragma module is named for THIS repository, never `metaPragmas`.
## Every Nim repo in this workspace ships one; they all land on the Nim path
## together, and the LAST --path entry wins -- so a shared name means one
## repo gets its own MetaTag list and the rest silently get someone else's.
## Rename this file and this line when you copy the template.
switch("path", "meta")
switch("path", "src")
# begin Nimble config (version 2)
when withDir(thisDir(), system.fileExists("nimble.paths")):
  include "nimble.paths"
# end Nimble config
