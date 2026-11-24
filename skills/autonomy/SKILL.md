---
name: autonomy
description: Per-thread sticky mode that cuts questions to the user. Switch on with "autonomy on", off with "autonomy off". While on, decide alone, get a second opinion from a same-model delegate, then an Opus delegate if still stuck, and ask the user only at hard stops.
license: MIT
compatibility: opencode
metadata:
  version: "1.0.0"
  domain: workflow
  triggers: autonomy on, autonomy off, trust your judgment, don't ask me, decide yourself, ask another model
  role: orchestrator
  scope: thread
  output-format: decision log
  related-skills: the-fool, grilling
---

# Autonomy

The user wants fewer questions in this thread. The mode stays on until the user says "autonomy off" or the thread ends. Say "Autonomy on" or "Autonomy off" once to confirm. Do not repeat it each turn.

## Effect on other rules

- Suspends the "present the plan and wait for approval before writing code" rule that applies under Ponytail full or ultra.
- Ponytail's level is unchanged: keep writing minimal code and reusing the existing codebase.

## Decision loop

When you face a choice you would normally ask the user about:

1. Decide, state the assumption in one line, keep going.
2. If the choice is hard, risky, or you are unsure, ask a delegate on the SAME model as you for a second opinion, using T3 `delegate_task`. A fresh context on the same model gives a slightly different perspective.
   - Call `orchestrator_capabilities` once per thread before the first delegation.
   - Use the research role and set effort explicitly in `target.options`.
   - The brief must say "do not edit files".
   - Take its answer unless it exposes a real flaw.
3. If the same-model delegate does not settle it (it disagrees, is unsure, or you are still stuck), delegate to an Opus model for a final opinion the same way. Say why Opus is needed in one line.
4. If `delegate_task` is unavailable (not in T3), say so in one line and decide alone. Never fall back to other tools or CLIs unasked.
5. Record each decision made this way as one short line in the reply so the user can review it later.

## Hard stops (always ask the user)

- Deleting data or files outside the task.
- Force pushes, pushes to main, deploys, permission changes.
- Sending outward-facing messages.
- Anything involving secrets or credentials.
- New domains, installers, or large downloads (see `~/.agents/network-security-rules.md`).
- Edits to AGENTS.md, CLAUDE.md, rules, hooks, or skills (use the diff-paste-and-wait rule).
- The real target differs from what the conversation assumed.

## Blockers

Keep working on independent items when one is blocked. Report concrete blockers at the end.
