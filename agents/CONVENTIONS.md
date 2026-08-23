# Proto Conventions
The project should always be written in Nim unless stated otherwise.
The conventions should stay local when in other repos outside of Proto-RepoTemplate and should not be committed - add them to the .gitignore list.

## Functions need custom pragmas.
These pragma definitions live in `.iron/meta/metaPragmas.nim`.
Do not write a second version of that file by hand in a child repo. Take the one from `Proto-RepoTemplate/meta/metaPragmas.nim`, change the `MetaTag` list, and leave everything else alone.
Only the `MetaTag` values are repo specific and should be extended/fit respectively.
Use `tag(...)`, not `tags(...)`, because `tags` collides with Nim's built-in pragma.
Keep the tag use to a minimum and focus on adding the roles correctly.
Enums and simple types do not need custom pragmas. Some important objects may need them though.

Otter reads these pragmas out of the tree to draw a repo's statistics, so the names are not ours to rename. A repo that renames them drops out of every chart.

## Tags and roles in other languages
Make sure the tags and roles are the same in other languages as they are in Nim. Use the same naming conventions as well. Since other languages do not support pragmas, just add these tags and roles via comments above the functions but wrap them inside the pragma notation still - just within the comment.

## Tests need to say what they are for.
`testKind` carries exactly one of `tkUnit`, `tkEdgeCase`, `tkBenchmark`, `tkRegression`, `tkBugfix`, `tkIntegration`, `tkFuzz`, `tkSmoke`, `tkProperty`, `tkOther`.
`covers` names the routine(s) under test. `pins` names the bug a regression test holds down.

```nim
proc wideRange() {.testKind: tkEdgeCase, covers: "parseWidth".} =
  ...
```

`test "..."` is a call to a template, so no pragma can be hung on it. Write the kind on the line above instead, in the same words:

```nim
# {.testKind: tkEdgeCase.}
test "an empty list is refused":
  check mean(@[]) == 0
```

A declared kind always wins. Without one the kind is guessed from the wording, and the tools report how many were declared and how many were guessed - so do not leave it to the wording for the tests that matter.

## No let declarations!
`let` declarations should ONLY be used for functions that have many if/case statements and where an initialization of each var for every branch is highly inefficient. Otherwise use var or const at the beginning of a function.
Give variables a default value and reassign later if needed.
Avoid declarations inside loops.

## No backwards compatability shims/double or triple facades - unless they have different jobs (compile time vs runtime inference is ok)

When we restructure an existing repo, breaking the API or the underlying archtitecture is FINE. 
Just because there are repos that call this project should never justify keeping old bloat.
Do not build or keep duplicate code/older API calls to dead code in the project after restructure.
Do not build unnecssary wrappers around already existing code unless they truly simplify calling and help with abstraction or overloading.
The only time when you should have different access layers is when having to compile parts of a project only.
Then it is necessary to split the repo into different when statements that compile specific modules only. 
This is especially important for IoT usage. Make sure that most low-level protocols always have that.

## No loop nesting! No if-statement nesting!
Instead, inline functions via pragma or use templates!

## No unnecessary, repeating "var", "const" or "type" identifiers in each new line!
Always define vars, consts and types in indented blocks!

## No complex logic! Build modular, parallel, multipass logic.
Adhere to the mantra: Perceive data -> build truth state -> act on parsed data
To make this possible, we use roles for data and functions, this also helps greatly with visualization and debugging.

### Type Roles
`rawData` <- Raw data from somewhere (network, input, file, etc.)
`preparedData` <- Prepared data (sanitized + decrypted)
`truthState` <- Truth state of the data
`memory` <- Regularly accessed data that needs to be stored in memory for performance reasons

### Function Roles
`dataFetcher` <- Grabs data from somewhere (network, input, file, etc.) and returns it via the `rawData` role object.
`decryptor` <- Decrypts data (if encrypted) and returns it via the `preparedData` object.
`sanitizer` <- Cleans data (remove invalid characters, etc.) and returns it via the `preparedData` role object.
(both sanitizer and decryptor are optional and can be combined)
`parser` (or `metaParsers`) <- Extracts information from `preparedData` role objects (or the `truthState`) and outputs `primitive` types only.
`truthState` <- An object/tuple/sequence/array that is supposed to hold parsed or generated data, to be acted upon regularly during runtime.
`truthBuilder` <- Builds a truth state from the parsed data and returns `primitives` - it does this by calling a bunch of `parser`functions and feeds it into the `truthState` object.
`actor` <- Reads the `truthState` and acts/computes on other data/output. It's decisions are based on information from the `truthState` role object only.
`orchestrator` (/metaOrchestrators) <- Coordinates the above functions (Calling sanitizer, decryptor, parser, truthBuilder, actor etc. in succession or in parallel).
`metaOrchestrator` <- Coordinates the orchestrators
`encryptor` <- Encrypts data (if needed) and hands it to the `dataWriter` or stores it in a `memory` role object.
`dataWriter` <- Writes data to somewhere (network, output, file, etc.)
`helper` <- Helper functions that do not fit into the above categories
`math` <- Math functions that perform complex calculations on any kind of data
`configurator` <- A type/object that accepts dev input for configuration of function behaviour. It should not be acted upon runtime often (mostly read only).
`other` <- For any functions that dont fall into any of the roles listed above.

## Some structural examples

How to avoid nesting with highlevel functions:

```nim
proc myFunc1(): void {.inline.} =
  ...

proc myFunc2(): void {.inline.} =
  ...

proc highLevelFunc(): int =
  myFunc1()
  myFunc2()
  ...
```

## Function Syntax

Avoid colon syntax for function calls.

Good example:
```
funcX(param1, param2)
```
or
```
param1.funcX(param2)
```

Bad example
```
funcX:
  param1, param2
```

## Naming and Parameter Rules

- Parameter names should use the first letter of what they represent.
- Explain parameter meaning below the function declaration with a `##` doc comment.
- Arrays, sequences, openArrays, and tables should use capital letters like `A`.
  - Example: an array of records -> `R`
- Some parameters should always use a special name, like `dir` for directory and `args` for arguments. Do that for the most generic ones. In these cases an uppercase letter is not needed, even though these are arrays.
- State objects to be mutated use `S`. If multiple, use `S0`, `S1`, `S2`, ...
- Math-heavy functions use `a,b,c` or `x,y,z` (then `x1`, `x2`, `x3`, ...).
- For arrays/lists in math functions, use uppercase letters like `X,Y,Z` or `A,B,C`.
- `t` is reserved for temporary variables inside functions.
- `i,j,k` are indices; `l,m,n` are lengths.
- Use `while` for complex loops; use `for` for simple one-call loops.
- If a function has only one parameter, you may use its first letter unless it collides with index identifiers.

## Result Variables

For clarity, you may assign to a temporary variable and set `result` at the end.

```nim
proc myProc(a, b: uint8): uint8 =
  var
    t: uint8 = 0 #this is basically the result, with an initialized default value
  t = callSomeOtherFunc(a, b)
  t = t + callYetAnotherFunc(a)
  result = t
```

## Declarations and Formatting

Always indent `var`, `let`, `const`, and `type` into blocks when declaring multiple values.

```nim
const
  c1: string = "hey" #use const where possible
  c2: int = 23
  c3: uint8 = 4
var
  t1: string = "" #initialize if possible to default values
  t2: int = 0
  t3: uint8 = 0
let
  t4: string = "holla" #avoid let definitions, unless for user inputs
  t5: int = 0
```

## Reuse and Compression

If you write three similar helper functions across modules, move them into `utils`. If you noticed them across repos, you may move them into Fylgia. And overload or use generics where possible. Do this regularly to keep the project lean and avoid unneeded bloat. Avoid giant function definitions after `when` statements. Use them inside wrapper .nim files that import and compile other .nim files only instead.

## Convention expansion

These conventions are expanded by the other .md files in this folder - please read them as well.