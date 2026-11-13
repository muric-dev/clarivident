# Clarivident
Read-only macOS TUI: what takes up disk space and why it changed.

## Commands
```sh
make check               # fmt, vet, lint, test, vuln, sizecheck, nonet
make sizecheck           # the only source for size limits: Go files, PR lines, agent files
make hook                # once per clone: runs scripts/hooks/pre-commit on every commit
make ledger              # updates ledger/usage.json and LEDGER.md (usage-ledger skill)
```

## Rules
- PR: one concept, ≤200 net production lines. Function ≤40. File ≤500.
- TDD: write a failing test first. Test product behavior, not coverage.
- No cgo and no network code: the binary must not link `net`, `net/http`, or `crypto/tls`. The parsers `net/url` and `net/netip` are allowed (bubbletea pulls them in). New dependencies need human approval.
- Read-only on user data: lstat and readdir only. The one write is the vault, inside `~/Library/Application Support/clarivident/` and only from `internal/vault`. Nothing else is created, written, deleted, moved, or opened. `forbidigo` in `.golangci.yml` enforces it.
- macOS 27.x only. System commands and constants live in internal/platform.
- ledger/usage.json never stores question text or paths.
- User data stays inside internal/vault. Never put paths or sizes in logs.
- The user stages, commits, and pushes. Never run `git add`, `commit`, `push`, `stash`, `reset`, or `gh pr create`, even when a skill says so, and never rewrite pushed history. Say the change is ready and give a commit draft. Guards: `permissions.deny` and `scripts/hook-guard.sh`.
- Commit drafts: `type(scope): <gitmoji> summary.`, for example `feat(scan): ✨ count hardlinks once.`
- Hand-off format is under Hand-off below.
- Tests use t.TempDir() or in-memory nodes, never the real disk.

## Hand-off
```
## <task>: done | blocked
Gates: make check <exit code> · sizecheck <net lines> · tests <passed/failed>
Changed: <files, one line each>
Decisions: <taken, with the reason, or "none">
Commit draft: type(scope): <gitmoji> summary.
Next: <one step>
```
Report the numbers you observed, not the ones you expect.

## Precedence
1. The user's current message.
2. The Rules above, then the `.claude/rules/` file for the path being edited.
3. The rest of this file.
4. General Go knowledge, only where none of the above applies. Say when you rely on it.

When two of these disagree and the order doesn't settle it, ask.

## Language
- Everything written to the repository is in English: code, comments, docs, tests, skills, rules, hook messages, and commit messages.
- Chat replies follow the user's language.

## Tooling
- `make check` is the gate, and it must exit 0 before a hand-off. Size limits come from `make sizecheck`, never from a number copied elsewhere.
- `CGO_ENABLED=0` disables the race detector, so `go test -race` is not available. Cover concurrency with deterministic tests: channels, fake clocks, and in-memory trees.
- Use the `gopls` MCP tools for symbol search, references, package API, and renames before falling back to text search.
- Hooks run on their own: `PostToolUse` runs gofmt on each edited `.go` file, `Stop` runs `sizecheck`, and the `usage-ledger` plugin saves the usage ledger. Fix what a hook reports. Never disable or bypass one.
- The git `pre-commit` hook runs when the user commits. Never use `--no-verify` or `SKIP_HAIKU=1`.
- Never edit `ledger/usage.json` or `LEDGER.md` by hand.

## Ask first
Ask before:
- creating or changing a skill, an agent, or a `.claude/rules/` file;
- changing hooks, `.claude/settings*.json`, `.mcp.json`, this file;
- going past the PR budget that `make sizecheck` enforces.

Give the options and your recommendation, then wait for the answer.
