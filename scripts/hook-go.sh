#!/bin/sh
# PostToolUse hook: format the Go file that was just edited.
# go vet is left to make check: it fails on purpose while a test is red or a refactor is half done.
file=$(jq -r '.tool_input.file_path // empty')
case "$file" in
"$CLAUDE_PROJECT_DIR"/*.go) ;;
*) exit 0 ;;
esac
[ -f "$file" ] || exit 0
# Only exit 2 shows stderr to the agent.
gofmt -w "$file" >&2 || exit 2
