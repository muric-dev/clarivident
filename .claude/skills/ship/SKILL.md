---
name: ship
description: Run /staged-audit on the branch and make ledger, then write the PR description for the user to open
disable-model-invocation: true
---

1. Run `/staged-audit branch`. It audits the committed `main...HEAD`, runs `make check`, and runs the go-reviewer agent.
   - The audit is read-only. List every P0 and P1 it confirms and stop. Fixing happens in a new message; after the user commits the fixes, audit again.
   - Stop and ask if the verdict is still not COMMIT after two rounds.
2. Run `/security-review` too if the diff touches `internal/vault`.
3. Run `make ledger`.
4. Write the PR title and description for the user to paste. It has what changes, one command to try it, the audit verdict, and the cost from `LEDGER.md`.
