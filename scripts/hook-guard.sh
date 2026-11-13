#!/bin/sh
# PreToolUse hook on Bash: the user stages, commits, and pushes, never the agent.
# Blocks git commands that change the index, history, or a remote, and gh commands that publish.
# Exit 2 is the only code that shows stderr to the agent.
cmd=$(jq -r '.tool_input.command // empty')
git_write='(^|[^[:alnum:]_-])git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*)?)*[[:space:]]+(add|commit|push|stash|reset|rebase|merge|cherry-pick|am|rm|mv|restore|checkout|switch|update-index|filter-branch|clean)([[:space:]]|$)|(^|[^[:alnum:]_-])git[[:space:]]+(branch[[:space:]]+-[dDmM]|tag[[:space:]]+[^-[:space:]])'
gh_write='(^|[^[:alnum:]_-])gh[[:space:]]+(pr[[:space:]]+(create|merge|edit|close|reopen|comment|review|ready)|release[[:space:]]+(create|edit|delete|upload)|repo[[:space:]]+(create|delete|edit|rename|fork)|issue[[:space:]]+(create|edit|close|comment))([[:space:]]|$)'
if printf '%s' "$cmd" | grep -Eq "$git_write|$gh_write"; then
	echo "guard: the user stages, commits, and pushes. Say the change is ready and give a commit draft." >&2
	exit 2
fi
# The vault holds user data. Any command that mentions its directory or file is blocked,
# whatever the tool (cat, grep, ls, cp...). Spaces may be escaped, quoted, or URL-encoded.
vault='[Ss]upport[^[:alnum:]]*clarivident|vault\.db'
if printf '%s' "$cmd" | grep -Eq "$vault"; then
	echo "guard: the vault is user data. Test it only through fakes and t.TempDir()." >&2
	exit 2
fi
