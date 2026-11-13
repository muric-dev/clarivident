---
name: staged-audit
description: Read-only audit of the staged diff (or a branch with `branch`): runs the gates, calls go-reviewer, gives a verdict. Use before a commit or PR.
argument-hint: "[branch]"
disallowed-tools: Edit Write NotebookEdit
---

# Staged audit

Audit exactly what goes into the next commit. With `branch` in $ARGUMENTS, audit `main...HEAD` instead.

Rules:
- Read-only: never edit a file or change the index. Never stage or stash to make the gates runnable.
- Staged mode audits the staged blob (`git show :<path>`), not the file on disk.
- Each finding proposes the smallest fix that solves it. No rewrites.

## Phase 1: Scope
1. Run `git status --short`, plus `git diff --cached` in staged mode or `git diff main...HEAD` in branch mode.
2. If the scope is empty, say so and stop.
3. List every Go file with changes outside the scope: unstaged ones in staged mode, and uncommitted ones in branch mode. For those files, the commit will differ from the disk.

## Phase 2: Gates
- If no `.go` file has changes outside the scope, run `make check` and record its exit code, the net lines that `sizecheck` reports, and the count of passed and failed tests.
- Otherwise don't run the gates. Write `not run: working tree differs from the scope in <files>`. 
- A failed build or test is a P0. A lint or fmt failure is a P3. A `sizecheck` or `nonet` failure is a P2 or a P0, as go-reviewer defines them.

Report the numbers you observed, never the ones you expect.

## Phase 3: Findings
If the scope has no `.go` file, skip this phase and write `Findings: none, no Go files in scope`. If every `.go` file in scope is a `_test.go` file, skip the reviewer and write `Findings: none, tests only`. Otherwise launch the `go-reviewer` agent once, with its default model, the scope from Phase 1 and the gate output. Check each P0 it returns against the code, and drop any whose line or scenario doesn't hold. Say how many you dropped.

## Phase 4: Report
Use this fixed format, with no extra prose:

```
## Verdict: BLOCK | FIX-THEN-COMMIT | COMMIT
<one line: why>

### Scope
<files, and what differs from the working tree>

### Gates
make check: <exit code | not run: reason> · sizecheck: <net lines> · tests: <passed / failed>

### Findings
<go-reviewer report after verification, plus "Dropped: n">
```

An open P0 makes the verdict BLOCK. An open P1 makes it FIX-THEN-COMMIT. Anything else is COMMIT, and P2 and P3 fixes can go in another commit.
