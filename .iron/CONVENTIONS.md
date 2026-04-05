# Proto Conventions
The project should always be written in Nim unless stated otherwise. Please follow these guidelines and conventions.

## All functions and custom types need custom pragmas.
These tags and pragma definitions live inside the .iron folder.
The tags type is repo specific and should be extended/fit respectively.

## No let declarations!
`let` declarations should ONLY be used for functions that have many if/case statements and where an initialization of
each var for every branch is highly inefficient. Otherwise use var or const at the beginning of a function.
Give variables a default value and reassign later if needed.
Avoid declarations inside loops.

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
`truthBuilder` <- Builds a truth state from the parsed data and return `primitives` by calling the parsers and feeding it into the `truthState` object.
`actor` <- Reads the `TruthState` and acts/computes on other data/output. It's decisions are based on information from the `truthState` role object only.
`orchestrator` (/metaOrchestrators) <- Coordinates the above functions (Calling sanitizer, decryptor, parser, truthBuilder, actor etc. in succession or in parallel).
`metaOrchestrator` <- Coordinates the orchestrators
`encryptor` <- Encrypts data (if needed) and hands it to the `dataWriter` or stores it in a `memory` role object.
`dataWriter` <- Writes data to somewhere (network, output, file, etc.)
`helper` <- Helper functions that do not fit into the above categories
`math` <- Math functions that perform complex calculations on any kind of data

## Debugging
For faster debugging, put a when

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
## Project Layout

The root of a repo should be structured into
```
/.iron <- folder for Iron-RepoCoordinator
/nix <-nix shell/dependencies (not always needed, only when UI or other dependencies required)
/src/protocols <- actual repo content 
/src/clients <- guis/uis/clis (not always needed, libraries will at max use a cli)
/src/server <- server architecture - loop, networking, etc.
/submodules <- submodules
/tests 
```

Order modules in the protocols by dependency level:
 
```
src/protocols/types.nim
src/protocols/level0/moduleX.nim <- depends on types only
src/protocols/level1/moduleXY.nim <- depends at least on moduleX
src/protocols/level2/moduleTZ.nim <- depends at least on moduleXY
...
```

This is not needed in the server and client directory.

In some libraries it might make sense to instead sort modules by role/name. 
That is especially the case, if a repo is a collection of many tiny algorithms/parsers/helpers.
In these cases, you can group them by module first instead of by dependency level.

Every (`.nim` file) must have a description at the top explaining what it does.
Prefer visual hints like arrows (`<- ->`), ASCII art boxes, and separators (`|`, `-`).

Make sure to add nimble tasks for all the builds/examples/tests so I can run them easily without flags.

## Reuse and Compression

If you write three similar helper functions across modules, move them into `utils` and overload or use generics (`when`/`case`) instead. Do this regularly to keep the project lean and avoid unneeded bloat.

## Documentation

Update the README when you make bigger project changes.

At the bottom of the README of a project, include a cleaner, more formatted version of these conventions so maintainers can quickly understand the programming style.

## Tools and Tests

- Add a `tools` folder when needed (for submodule builders or other pre-compile time utilities).
- Always include a `test` folder with unit tests for important functions.
- After changing code or dependencies, run tests and fix errors.

## UI guidelines

If given the prompt to create a UI without specifics, you are to create it with the nim-webui library, using typescript, html and css. The UI should adhere to the following principles:
It should consist of a main grid which differentiates between main-menu, main-content, extra-menu.
The main-menu is either located in the top cell or the side (usually the top). The extra-menu is usually at the bottom.
The main-menu should always include a searchbar which either extends upon click or is always extended and sits flush with the rest of the menu buttons. 
By default there should be no gap between buttons or the searchbar. The buttons and the searchbar should all be of equal height. Every button should have a symbol/icon written with the ArtofCreation-font and the actual text next/below it. 
If there is a sub-menu needed that changes per main-menu, it should be added in the same cell as the main-menu via a grid. The grid should have one column or row for the main-menu and then the other for the sub-menu which switches with each button press of the main-menu.
The main content contains data of different kinds - if it is text focused data then it should be displayed as a list with columns. 
Avoid padding and flexbox usage for bigger containers. You may only use padding in containers that display text directly with no nested divs inside. 

## UI Theming
By default, use these colors:
#121419;
#ddeaf6;
#7e98b7;
#0b1118;
rgba(43, 48, 56, 0.9);

Data elements should have a dark transparent background with a backdrop-blur with a white, bold, white-shadowed font. 
The main background of the body should be a black-grey gradient with a blueish tint. 
To contrast this, some additional buttons can have a white background with a small greyish border around them and a black font (of they are tiny and important, to make them pop out more). 

## UI Seperation and visibility
Define colors somewhere at a top level in the css and then reuse them strategically.

To increase visibility of items/elements use: 
- very slight colored gradients (with one end transparent) as background overlays.
- one-sided colored borders  
- colored text 
- background bezier curves with transparent end and start, but visible middle part (with a glow)
- inverse background and text color compared to the rest of the UI
- small grey border around an element

This should be done to: 
- group elements by function/attribute (`glue` color <- e.g.: menu/tags from data/elements)
- grab the users attention and guide him through the UI (`recommendation` color <- e.g.: first-time setup/common settings)
- separate big chunks/parts of the menu from other parts (`separator` color <- e.g.: different sections in the main-content)
- highlight smaller parts of the UI, to make up for their size by color (`tiny` color <- e.g.: badges)

## UI Clutter

Avoid titles or descriptions of panels/contents at all costs! The user should understand their purpose by placement and coloring and the actual information inside the panel only. Use tooltips for buttons/elements whose functionality/data is too complex to understand without description.

Avoid padding and margins at all costs! Do only add them in elements that do not contain other elements (except text).

## UI Loginscreen

Any UI that can have multiple accounts (most) should have a profile selection screen and maybe even a password and username field together with a registration field. The login screen/profile selection screen should have a floating panel in the middle. It should be positioned via a 3x3 grid and only occupy the middle cell. The login panel in the middle cell should be a separate grid. At the top it should have three buttons, flush with no gaps that switch between login, register and recover. The profile list should be a seperate panel positioned in the left, right or top cell of the main 3x3 grid.

## UI Strategy

Before you start writing the UI, identify these things:
- What kind of data will the user handle? (table-like data/json-like data/text/images/references to data/videos)
- Will the user handle multiple kinds of data? (then maybe each menu needs to have different visuals for teh data)
- How should it be displayed? (List/Grid/Cards)
- What are the main things that user wants to do with the data? (Read/Sort/Edit/Share/Share parts of it)
- Which parts of the data need to be read/edited/shared/sorted?
- Should these functions be implemented per data-element or activate for all elements simultaneously or both via different buttons? 
- Where should the buttons live?

## UI Functions

In general, for the data-elements, we decide between two different functions:
1. Functions that only affect one data-element
2. Functions that affect multiple data-elements

Functions that affect only one data-point/element should have their button located in a menu that is close to the element or on the element itself. Alternatively, if there is a section that specifically only exists to show a menu/details that are data-element specific, then these kinds of buttons can live their as well.

Functions that affect multiple data-elements should live in a space somewhere that is shared by all data-elements of the current main-content.

## .iron Folder (Repo Coordination)

Every repo must have a `.iron/` folder located next to `src/`.

- Store repo-coordination configs and templates there.
- Use `Proto-RepoTemplate/.iron/` as the template source.
- The local submodule override file lives at `.iron/.local.gitmodules.toml` and should be ignored by git.

## C Bindings (cNimWrapper)

We have a cNimWrapper in the parent directory where all projects live. It should accurately create bindings for C libraries. If you need bindings for a C-only repo, you may use it and clone the repo without asking.

## Shared Utils (Fylgia-Utils)

There is a repo called "Fylgia-Utils" (git URL: https://github.com/siriuslee69/fylgia-utils).
- It may contain tools and other things you will reuse.
- Put generic helper functions there when appropriate.

## Shared SIMD library (SIMD-Nexus)

There is a repo called SIMD-Nexus which exports high-level bindings for nimsimd. 
It also features utility functions like simd string searching.
Use where appropriate.

## Nimsuggest

Do not write pre-compile time import statements that prevent nimsuggest from checking functions.

## progress.md

Inside each project, create `progress.md` inside .iron (if it does not exist) and track:

1. Current commit message (update after every change)
2. Features to implement (total)
3. Features already implemented
4. Features in progress

And also:

1. Last big change or problem encountered
2. How you tried to fix it, and whether it worked

## .nimble Tasks

Create a `.nimble` file with tasks for:
1. Test runs (call after each change)
2. Builders
3. Autopushing

## Configs

Every project should have a parser module for a config.toml file which sets global vars inside the lib and an additional parser for the userconfig.toml if it is meant to be used as a client.

## Compatibility

In general, all the projects are meant to run on Linux and Windows. Specifically Windows 11 and NixOS. 
Both should have first-class support and run out of the box. 
You may follow the general structure of the rest of this Proto-RepoTemplate repo and the example files.

## Issue Playbook

Create an issue playbook at the bottom of the README.md which lists common issues/workaround for bugs and problems that have been encountered and could not be fixed or are only fixed superficially. Some of them may be at risk of greater degradation when they are just patching other imported and broken submodules/repos. The users should know of these in advance.

## Conventions

Keep a copy of this .iron folder and its contents in each repo.
Make sure to change the path in .local.config.toml in the .iron folder accordingly.

