## Philosophy

Keep it simple, keep it modular.
Evaluate projects by how easy they are to understand and how easy it is to use them for the end-user.
API calls should be intuitive. All projects should have simple examples on how to be used.
Write the examples first before you start anything.
Then afterwards, try to adhere to these examples for calling/API convention or make them even simpler.
Keep type definitions minimal and - where possible - modular and embrace the use of functions/methods more.

## Requests

Make sure you adhere to "common sense" when I make requests, such that a feature I ask you to implement is not implemented ONLY in the parts I asked for, but also with the respective harness and necessary precursors around it. If you are unsure on how many things to implement, ask me once more to specify.

## Maintainability

The goal is to write repos in such a way that they are easily understood and maintainable by humans even without AI. You should never lose sight of this - whatever you do has to be well documented and explained with examples either in the docs/readme or as comments/doc-comments.
Your explanations have to be low-level but structured. No high-level abstractions - these dont help with maintaining the projects. Try and visualize explanations with ASCII/Unicode flowcharts etc.

## Readme layout

At the top of the README should be an example on how to install. No bloat around it, just "Installation: " and then the different steps for the different OS systems. Since we only focus on NixOS and Windows 11 (and maybe Android) we dont have to worry about the rest atm.
For some repos that have different API layers/entrypoints (direct via code or from a CLI to a daemon with different daemons) we have to split the installation guides cleanly by use-case, too. 
After each installation guide should also follow a quick start-up (if needed for the daemon) and usage guide (actual commands/functionality tests).
Make sure to also write down where the configs reside and what options should stay default vs what the user is free to change.

THEN come the actual explanation of how the stuff works. We go with a top-down explanation - explain first at a high-level without technical terms (use very simple everyday vocabulary) what the repo does and how it does it and how its structured. Then give each of these things proper technical terms and go into more detail. Make sure to use references to earlier definitions and such. It's best if you keep it a bit math-like ('Def. 1: TermX is ...' or 'Example 1: Myexample ...') etc.
You are free to define many terms at once clearly and also visually.
Especially with low level stuff the README HAS to have exact byte/bit order, edge-case observations and the bytes functionality in them too.
I dont want sentences like this:
'The magic bytes are prepended to each frame inside DAC.' 
The problem is that the user has to know three technical terms to understand this sentence AND when he looks at the entire DAC + AME framing he might see a second magic block from AME which will immediately confuse him. 
A simple, ASCII/Unicode frame with proper naming and explanation beneath would be much, much better.

## Writing style

1. For instructions, you may use 'We' as a pronoun. 
E.g.:
We can change this settings by calling the `setConfig()` function ...
```
import myApp
var myCustomValue: int = 5
discard setConfig(mySettingKey = myCustomValue) #returns 1 if successful otherwise 0, but we don't need that so we discard the result

2. For more scientific explanations (especially when it comes to dedicated architecture/benchmark docs), you may use passive and gerunds.
E.g.:
- This was done to... 
- Deriving a key will also ...

3. Try to keep sentences short and tight with simple vocabulary. Do not add filler words like `of course, naturally, obviously`.

4. Keep sentence structure the same. Do NOT write elobarate stuff. In a perfect world the user should understand at which part of the explanation he is at the moment, simply by how you start the sentence. 

5. Use unicode art, nature/food/structure emojis for chapters and overall structure. You may choose from the ones below - but you are free to create your own too. 

l🎀】🆁🆄🅻🅴🆂◂
▰🎀▰ ＲＵＬＥＳ
◢🎀◣ ⓇⓊⓁⒺⓈ
┃🎀 R・U・L・E・S◂

❮💕❯⤎guide
♡ guide ʕ•́ᴥ•̀ʔっ♡
┊guide┊٩˘◡˘۶
ʚ♡ɞ・guide
₊˚⊹♡ guide ♡⊹˚₊
꒰ঌ guide ໒꒱
༺ guide ༻
꧁ guide ꧂
⌜guide⌟

╭『❖』chapter0Name 🌊
︙『✜』chapter1Name 🐦‍🔥
╰『✜』chapter2Name 🍣

╭─ ❧ chapter0Name 🌊
├─ ❧ chapter1Name 🐦‍🔥
╰─ ❧ chapter2Name 🍣

╭⟢ chapter0Name 🌊
├⟢ chapter1Name 🐦‍🔥
╰⟢ chapter2Name 🍣

Some other bracket styles:

【 】  『 』  「 」  〖 〗  〘 〙
《 》  〈 〉  ❮ ❯  ❰ ❱
⟦ ⟧  ⟬ ⟭  ⦗ ⦘  ⧼ ⧽
꧁ ꧂  ༺ ༻  ꒰ ꒱
୨୧  ʚɞ  ꒰ঌ ໒꒱
❖ ✦ ✧ ✜ ❧ ⟡ ◈ ⟢
╭ ╮ ╰ ╯ ┊ ┃ ︙

6. Use up to two Kaomoji per chapter to signify an especially important line or example.

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
Prefer visual hints like arrows (`<- ->`), ASCII/Unicode art boxes, and separators (`|`, `-`).

Make sure to add nimble tasks for all the builds/examples/tests so I can run them easily without flags.


## Documentation

Update the README when you make bigger project changes.

At the bottom of the README of a project, include a cleaner, more formatted version of these conventions so maintainers can quickly understand the programming style.

## Git

Make sure all repos are git tracked and the .gitignore file contains builds, temporary data and user specific files. Git commit after each code change.

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

For the nimble git tasks (`autopush`, `switch`, `applynightly`) do not write
your own versions: copy them verbatim, together with their helper procs
(`resolveProgressPath`, `resolveGitIndexLockPath`, `resolveAutopushMessagePath`,
`resolveCommitMessage`, `captureGit`, `isGeneratedOrLocalArtifact`), from
`Proto-RepoTemplate/proto_conventions.nimble`. Extend
`isGeneratedOrLocalArtifact` with repo-specific artifacts when needed.

## Configs

Every project should have a parser module for a config.toml file which sets global vars inside the lib and an additional parser for the userconfig.toml if it is meant to be used as a client.

## Compatibility

In general, all the projects are meant to run on Linux and Windows. Specifically Windows 11 and NixOS.
Both should have first-class support and run out of the box.
You may follow the general structure of the rest of this Proto-RepoTemplate repo and the example files.

## Issue Playbook

Create an issue playbook at the bottom of the README.md which lists common issues/workaround for bugs and problems that have been encountered and could not be fixed or are only fixed superficially. Some of them may be at risk of greater degradation when they are just patching other imported and broken submodules/repos. The users should know of these in advance.

## Dirtyness

If you start working on a dirty repo, commit everything currently in it and add your own commits on top. This is supposed to be the standard for any repo that belongs to SiriusLee69 or doesn't have an owner.

## Conventions

Keep a copy of this .iron folder and its contents in each repo.
Make sure to change the path in .local.config.toml in the .iron folder accordingly.

## Production Readiness

When I tell you to make something production-ready, I expect the following:
1. Add correct licensing files for third party code or documents if necessary.
2. Add builds, assets and runtime dependencies etc. to .gitignore.
3. Add all dependencies that are required for this project via the nimble file and the submodules folder as a git submodule. They shouldn't live anyhwere else.
4. All API calls that are user/dev facing should be simple and intuitive and modular if possible.
5. All API calls should have a sanitization function sitting behind them if they handle raw user input.
6. The repo's .iron folder should be updated with the current .iron folder from Proto-RepoTemplate, except for the meta folder which may contain repo-custom code.
7. There should be a docs folder, which contains .md files on benchmarks, tests, code layout and structure with ASCII/Unicode tables for better visualization and ASCII flow-charts. The same extensive treatment should be given to the CONTRIBUTING.md.
8. Clear up any unneeded code and artifacts from prior refactors, name changes, API changes or tests. Specifically functions/code/tests that seem to be duplicate in nature and have no clear seperate functions/roles within the repo. In these cases, determine which one seems more polished or newer and remove the other. If unsure, ask me first.
9. Remove any user specific paths, keys and similar data from the repo.

## Nimble tasks

Make sure to hand-off any project I give you to work on with nimble tasks that let me run the different frontends.
Call them `runWebui`, `runOwl`, `runIll` by default after their respective frontend libraries (nim-webui, owlkettle, illwill).
Additionally, make sure to create nimble tasks `applynightly`, `switch`, `autopush` as they are in this repo.
