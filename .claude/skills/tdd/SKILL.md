---
name: tdd
description: Write a failing test, add the minimum code, and run make check
argument-hint: "<task>"
disable-model-invocation: true
---

Build $ARGUMENTS.

1. Read the matching `docs/features/` file if there is one, and the package's existing tests.
2. Write a failing test for the product behavior. Run it and confirm it fails for the expected reason.
3. Add the minimum code that passes.
4. Run `make check` and fix what it reports.
5. Stop with the hand-off from `CLAUDE.md`. The user stages and commits.
