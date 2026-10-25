@AGENTS.md

# Dale Otra Vida — working agreement

App spec: `docs/design-system.md` (UI tokens/components). Prototype: 6 screens (login, home,
listing detail, chat, publish, profile). Solo developer, 1-week deadline, Android + iOS, Spanish UI.

## Model routing (save tokens on simple work, be precise on complex work)

Claude Code plans, designs the data model, reviews and verifies. OpenCode executes well-specified
tasks. Pick the cheapest model that can do the task right; escalate only after a failed attempt.

| Work | Who / model |
|---|---|
| Doc lookups, reading package source, codebase searches | Claude subagent `Explore` with `model: haiku` |
| Medium analysis (review a diff, debug a known failure) | Claude subagent with `model: sonnet` |
| Architecture, data model, auth/security, final review | Claude main session |
| Mechanical edits, renames, boilerplate, formatting fixes | `opencode run -m opencode-go/mimo-v2.6-flash` |
| Implementing a written spec (UI screens, endpoints with tests) | `opencode run -m opencode-go/kimi-k2.7-code` |
| A task that failed twice, or tricky multi-file logic | `opencode run -m opencode-go/glm-5.2` |

Delegation rules:
- Every OpenCode task gets an exact scope (files it may touch), acceptance checks
  (`dart analyze`, `flutter analyze`, tests) and "no commits".
- Claude verifies every delegated result (diff + analyze + tests) before committing.
- Never start the server for the user (see AGENTS.md); server tests run with `dart test`.
