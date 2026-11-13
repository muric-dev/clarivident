#!/bin/sh
# PreToolUse hook on Bash for read-only tasks (reviews). Allowlist, not denylist:
# only plain read commands run, so nothing can delete, modify, or redirect output.
# Exit 2 is the only code that shows stderr to the agent.
cmd=$(jq -r '.tool_input.command // empty')
# No chaining, pipes, redirects, substitution, or git flags that write a file.
unsafe='[;&|<>`]|\$\(|--output|--ext-diff|--textconv'
allowed='^(git (diff|show|log|status|rev-parse|ls-files|blame))([[:space:]]|$)'
if printf '%s' "$cmd" | grep -Eq "$unsafe" || ! printf '%s' "$cmd" | grep -Eq "$allowed"; then
	echo "read-only: this task only runs git diff/show/log/status/rev-parse/ls-files/blame, one command at a time." >&2
	exit 2
fi
