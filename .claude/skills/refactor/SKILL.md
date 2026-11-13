---
name: refactor
description: Refactor one Clarivident package so it follows CLAUDE.md without changing behaviour. Finds over-abstraction, dead code, reinvented code, and drift, proposes a plan, and stops for approval before touching code
argument-hint: "<package, e.g. internal/scan>"
disable-model-invocation: true
---

Refactor $ARGUMENTS with the smallest change that brings it in line with `CLAUDE.md`. Behaviour stays the same unless the plan says otherwise. A bug found along the way is a decision, not a side effect.

Refactor one package per run. If the request covers more, or the fix needs another package's exported API to change, ask.

## Phase 1: Inventory
1. Read every file in the package and its tests in full.
2. Use `gopls` references to find every caller of its exported symbols outside the package.
3. List what it imports from other internal packages.

## Phase 2: Findings
Each finding gets `file:line`, what is wrong, and the smallest fix. Drop any finding you can't point to a line for.

1. **Lenses:** apply the Architecture and Simplicity lenses from `.claude/agents/go-reviewer.md` to the whole package.
2. **Dead code:** call an exported symbol dead only after `gopls` finds zero references. Code that only tests use is a decision, not a finding.
3. **Reinvented code:** logic the stdlib or another package here already provides. Two copies is a note; three means extract.
4. **Docs:** an exported identifier without a doc comment, or a comment that no longer matches the code.
5. **Bugs found along the way:** record them without fixing them. Each one becomes a decision.

## Phase 3: Plan, then stop
Reply with the plan:

```
## Refactor: <package>
Steps: <ordered; each one compiles and keeps make check green>
Decisions: | Decision | Choice | Why |, including what deliberately stays
Tests first: <tests that pin current behaviour, and what each one pins>
Open questions: <what you need from the user, or "None">
```

Then stop and wait for approval. Never pick a default for an open question.

## Phase 4: Apply (after approval)
1. **Pin behaviour first:** add the tests from the plan and confirm they pass on the old code. A test for a bug fix must fail on the old code.
2. **Work step by step, in order:** move code before changing it, so each diff stays readable. After each step, `make check` exits 0.
3. **Stop on surprises:** if a step reveals something the plan doesn't cover, stop and ask.
4. **Final pass:** run `/simplify` on the diff, then `make check`.

## Phase 5: Hand off
Reply with the hand-off from `CLAUDE.md`, titled `Refactor <package>`, with commit draft `refactor(<package>): ♻️ <summary>.`. Then suggest `/staged-audit` once the user stages the change.
