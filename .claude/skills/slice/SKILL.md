---
name: slice
description: Split a feature into PRs within the size budget, with acceptance examples
argument-hint: "<feature name>"
disable-model-invocation: true
---

Slice feature $ARGUMENTS.

1. Read the code and docs the feature depends on.
2. Write `docs/features/$ARGUMENTS.md` in English, with input and output tables that can become tests.
3. Split the work into PRs of one concept that `make sizecheck` accepts. Each PR must merge alone, compile, and leave the product working.
4. Reply with the ordered PRs: what changes, a command to try it, and estimated lines.
