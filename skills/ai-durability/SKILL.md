---
name: ai-durability
description: Sets up and audits a project so its typing, architecture, and agent rules stay intact while many cheap AI agents work on it in parallel. Two modes — SETUP (strict typing with ratchet baseline, boundary checks, synced AGENTS.md/CLAUDE.md, single check command, CI gates, anti-weakening checks, CODEOWNERS, metrics) and AUDIT (read-only periodic drift report with pass/warn/fail). Use when the user wants a project "AI-proof", "intact", "durable", asks to set up guardrails for AI agents, wants to check whether typing/architecture/rules still hold, or says "audit the project's AI readiness". Complements constraint-driven-development (quality bar) and does not replace it.
---

# AI Durability

Goal: a project whose structure survives many cheap agents working in parallel. Principle: **cheap agents execute, the system verifies.** Rules in prose get ignored; rules in tooling and CI do not.

Pick the mode from the user's request. If unclear, ask once: setup or audit?

## Mode: SETUP

Work on a new branch/worktree `chore/ai-durability-setup`. Never push to main. Small commits, one per phase.

### Phase 0: Discover (read-only)
1. Detect language(s), framework, package manager, build/test/lint commands, existing CI.
2. Map real structure: top-level folders, entry points, layers, actual dependency directions.
3. Find existing rules files (AGENTS.md, CLAUDE.md, .cursorrules), type/lint config, tests.
4. Record baseline: counts of `any`, `as unknown as`, `@ts-ignore`, `@ts-expect-error`, `# type: ignore`, `eslint-disable`, skipped tests; strict-mode error count; duplication %. `scripts/audit.sh` does most of this.
5. Report in ≤15 lines and propose target layers + allowed dependency directions. Ask only if genuinely ambiguous.

### Phase 1: Strong typing (mandatory)
- Strictest practical mode (TS: `strict`, `noImplicitAny`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes` where feasible; Python: mypy --strict or pyright strict; others: strictest equivalent).
- If strict yields many existing errors, do NOT loosen config. Use a ratchet: store the count in `.ai/baseline.json`, fail only if it increases; new/changed code fully strict.
- Ban untyped escape hatches in new code via lint (`no-explicit-any`, ban-ts-comment).
- Shared boundary types in one obvious place.

### Phase 2: Architecture enforcement
- `docs/ARCHITECTURE.md` (one page): purpose, components, layers, allowed dependency directions, where new code goes, what must never happen, one Mermaid diagram.
- Boundary checker (dependency-cruiser / eslint-plugin-boundaries / import-linter or equivalent). Existing violations in an explicit shrinking allowlist; new ones fail.
- Structure check failing on new top-level folders or files outside documented layout.
- Duplicate/dead-code detection (jscpd, knip, vulture or equivalent).
- `docs/decisions/` with ADR template and one ADR for current key decisions.

### Phase 3: Agent rules (single source, synced)
- `AGENTS.md` is the single source, <100 lines, imperative, most important first: purpose, folder map, layer/dependency rules, typing rules, conventions, the `check` command, DO-NOT list (no new deps without asking; no new top-level folders; never edit tests/config/contracts to make checks pass; search for existing helper before writing one; stay in the task's allowed paths).
- `CLAUDE.md` symlinks to `AGENTS.md` (or one-line pointer). Same for other agent rule files.
- Check that fails if they diverge or if paths named in AGENTS.md / ARCHITECTURE.md no longer exist.
- Short README per major module: purpose, public interface, allowed dependencies.

### Phase 4: One command, CI, gates
- Single `check` command: strict types, lint, boundaries, structure, duplicate/dead code, rules-sync, tests, anti-weakening.
- CI runs `check` on every PR and on main.
- Anti-weakening check: fail on new suppressions, skipped/deleted tests, lowered thresholds, loosened type/lint/CI config unless PR is labeled for a config change.
- CODEOWNERS for: type/lint/boundary config, CI workflows, ARCHITECTURE.md, decisions/, AGENTS.md, contracts/shared types, test config.
- Pre-commit hook running the fast subset.
- Document branch protection the user must enable manually (PR only, required CI, required CODEOWNERS review, no force-push). Do not change remote settings.

### Phase 5: Audit and metrics
- `scripts/audit.sh` (start from this skill's `scripts/audit.sh`) writes `.ai/metrics.json`, exits non-zero if worse than baseline.
- Weekly scheduled CI job runs it and opens/updates an issue.
- `docs/AI_WORKFLOW.md`: worktree+branch per task, PRs only, task template (goal, allowed paths, interface, acceptance commands, don'ts), monthly 15-min manual review checklist, quarterly "plant a violation, confirm CI fails".

### Rules during setup
- Never loosen checks, delete tests, or add suppressions to get green.
- No app-code refactors beyond installing guardrails; list existing violations for later.
- Prefer tools already in the project; list every dependency added.

### Final output
1. Table of phases: done/partial/skipped + why.
2. Baseline metrics and where stored.
3. Exact `check` and `audit` commands.
4. Prioritized existing violations with rough size.
5. Manual steps for the user.
6. Verification: `check` passes clean; for each gate, introduce one violation (an `any`, forbidden import, new top-level folder, config edit, divergent CLAUDE.md), confirm failure, revert.

## Mode: AUDIT (read-only, no edits)

Run `scripts/audit.sh` if the project has none, else its own. Then inspect and report a pass/warn/fail table:

| Category | Check |
|---|---|
| Typing | strict on; `any`/suppression counts vs baseline; type check in CI |
| Config weakening | `git log -p` on tsconfig/lint/CI/boundary config: anything loosened? |
| Bypasses | skipped/deleted tests, eslint-disable, lowered thresholds, `--no-verify` |
| Architecture | boundary checker passes; allowlist size trend; new top-level folders; ARCHITECTURE.md matches code |
| Duplication/dead code | tool output vs baseline |
| Rules sync | AGENTS.md/CLAUDE.md identical or symlinked; referenced paths exist |
| Agent control | direct pushes to main, merges without checks, protected files changed without owner approval, PRs outside task scope |
| Gates alive | CI required, branch protection on; offer the "plant a violation" test |

Output: the table, metric trend (should only go down/flat), top 5 fixes in priority order, and which items need a human architecture decision (ADR). Do not fix anything unless asked.
