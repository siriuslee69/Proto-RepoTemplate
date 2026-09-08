## This file should be imported across all files inside src.
##
## RENAME IT when you copy this template: `meta/<yourRepo>Pragmas.nim`, and
## change the `switch("path", "meta")` line in config.nims to match. Never
## leave it called `metaPragmas`.
##
## Every Nim repository here ships one of these and they all end up on the
## Nim path together. Nim takes the LAST --path entry that matches a module
## name, so a shared name means exactly one repository compiles against its
## own `MetaTag` list and the others silently get that repository's -- then
## fail on the first tag their own list has, several imports from the cause:
##
##   padding.nim(84, 33) Error: undeclared identifier: 'tagCryptoBoundary'
##
## Distinct names cannot capture each other in any path order, and they let
## the import stay flat (`import yourRepoPragmas`) from any depth, so moving
## a file never breaks its pragma import.
## Only the MetaTag values are meant to be changed. Keep the pragma names as-is.
## Use `metaTags(...)`, not `tags(...)`, because `tags` collides with Nim's
## built-in pragma.
##
## This file is the one every repository copies. Do not write a second
## version of it by hand in a child repository: take this one, change the
## MetaTag list, and leave everything else alone. Otter reads these
## pragmas to draw a repository's statistics, so a repository that
## renames them drops out of every chart.
##
##   src/       -> role / input / risk / speed / metaTags / stage
##   evaluation -> testKind / covers / pins
type
    MetaRole* = enum
        helper, math,
        dataFetcher, decryptor, sanitizer, parser, truthBuilder, metaParser,
        actor, orchestrator, metaOrchestrator, encryptor, dataWriter,
        configurator,
        other,
        rawData, preparedData,
        truthState, memory

    MetaInput* = enum
        user, llm, thirdParty, trusted
    MetaRisk* = enum
        `low`, `medium`, `high`
    MetaSpeed* {.pure.} = enum
        fast, medium, long, `data-dependent`
    MetaIssue* = tuple
        name: string # short description or name
        id: uint64 #issues id/reference
    MetaIssues* = seq[MetaIssue]
    MetaTag* = enum
        tagOther # Put repository-specific tags here.
    MetaTags* = set[MetaTag]

    MetaTestKind* = enum
        ## What one test is for. A test carries exactly one of these, so
        ## the suite can be read as a shape rather than a list of names.
        ##
        ##   tkUnit         one proc, ordinary input
        ##   tkEdgeCase     the ends of the range: empty, zero, one, huge
        ##   tkBenchmark    speed or size, measured rather than asserted
        ##   tkRegression   something that broke once and must not again
        ##   tkBugfix       one named bug, pinned by `pins`
        ##   tkIntegration  several parts together
        ##   tkFuzz         random or generated input
        ##   tkSmoke        the thing starts at all
        ##   tkProperty     a law that must hold for every input
        ##   tkOther        anything the list above does not cover
        tkUnit, tkEdgeCase, tkBenchmark, tkRegression, tkBugfix,
        tkIntegration, tkFuzz, tkSmoke, tkProperty, tkOther
    MetaTestKinds* = set[MetaTestKind]

    MetaStage* = enum
        ## How finished one routine is. A routine without this pragma is
        ## taken to be finished; the pragma exists so that a routine
        ## that is NOT finished can say so out loud, instead of being
        ## guessed at from the wording of its body.
        ##
        ##   stStubbed     declared, and does nothing yet
        ##   stPartial     some of it works, some of it does not
        ##   stDeprecated  still here, on its way out
        ##   stDone        finished, said explicitly
        stStubbed, stPartial, stDeprecated, stDone

template input*(x: MetaInput) {.pragma.}
template input*(x: set[MetaInput]) {.pragma.}
template role*(x: MetaRole) {.pragma.}
template role*(x: set[MetaRole]) {.pragma.}
template risk*(x: MetaRisk) {.pragma.}
template speed*(x: MetaSpeed) {.pragma.}
template issues*(x: MetaIssues) {.pragma.}
template metaTags*(x: MetaTags) {.pragma.}
template stage*(x: MetaStage) {.pragma.}

template testKind*(x: MetaTestKind) {.pragma.}
template testKind*(x: MetaTestKinds) {.pragma.}
template covers*(x: string) {.pragma.}
template covers*(x: seq[string]) {.pragma.}
template pins*(x: MetaIssue) {.pragma.}
template pins*(x: MetaIssues) {.pragma.}
