# Contributing to proto-conventions

## Purpose
This repo is the shared reference point for humans and agents working across the workspace. Changes here should improve consistency, not add repo-specific implementation details.

## What belongs here
- repo layout conventions
- documentation templates and checklists
- Ratatoskr pragma/tag guidance
- agent-facing architecture expectations

## What does not belong here
- runtime code for Mimir, Hugin, or other product repos
- repo-specific implementation notes that are only relevant to one project
- machine-local paths, tokens, or generated binaries

## Architecture documentation checklist
When you create or update a repo, make sure its `README.md` covers:
1. repo role and boundary,
2. neighboring repos and their boundaries,
3. main state types,
4. important orchestrator functions,
5. loop entrypoints,
6. normal request/data flow,
7. examples.

Its `CONTRIBUTING.md` should cover:
1. what belongs in the repo,
2. what does not belong there,
3. which files matter most,
4. which functions to understand before changing behavior,
5. review checklist,
6. commands/tests to run.

## Publish hygiene checklist
Before pushing changes here or copying templates into another repo:
1. keep tracked `.iron/.local.config.toml.template` values relative or placeholder-safe,
2. copy machine-local values into ignored `.iron/.local.config.toml`,
3. do not commit generated binaries, local `nimble.paths`, or editor state,
4. update `README.md`, `CONTRIBUTING.md`, and `.iron/CONVENTIONS.md` together when conventions change,
5. run `nimble test`,
6. compile any entrypoints you touched.

## Ratatoskr pragma guidance
Prefer explicit proc pragmas for important functions. Recommended fields:
- `role`
- `risk`
- `issue`
- `tag`
- `tags`
- `user_input`

Recommended bare tags:
- `entrypoint`
- `orchestrator`
- `state_controller`
- `scheduler_loop`
- `network_surface`
- `storage_io`
- `protocol_bridge`
- `app_api`
- `crypto_boundary`
- `codec_boundary`

## Review Checklist
- Does the change improve shared guidance rather than one repo only?
- Does it stay concrete enough to be actionable?
- Is it consistent with current split-repo architecture?
- If you add a new convention, is there a clear reason for it?
- Does the repo stay publish-safe after the change?
