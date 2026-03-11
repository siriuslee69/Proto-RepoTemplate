## This file should be imported across all files inside src.
## Only the tags are meant to be changed! Everything else should be kept as is!
type
    MetaRole = enum
        helper, math, parser, metaParser, actor, orchestrator, metaOrchestrator,
            truthBuilder, truthState, other
    MetaInput = enum
        user, llm, thirdParty, trusted
    MetaRisk = enum
        `low`, `medium`, `high`
    MetaIssue = tuple
        name: string # short description or name
        id: uint64 #issues id/reference
    MetaIssues = seq[MetaIssue]
    MetaTag = enum
        other #put your custom tags here
    MetaTags = set[MetaTag]

template input*(x: MetaInput) {.pragma.}
template role*(x: MetaRole) {.pragma.}
template risk*(x: MetaRisk) {.pragma.}
template issues*(x: MetaIssues) {.pragma.}
template tags*(x: MetaTags) {.pragma.}
