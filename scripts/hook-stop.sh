#!/bin/sh
# Stop hook: exit 2 sends the agent back to work, and make itself exits 2 on
# failure. Report an overrun once, then let the turn end instead of looping.
[ "$(jq -r '.stop_hook_active // false')" = true ] && exit 0
make -s -C "$CLAUDE_PROJECT_DIR" sizecheck >&2 || exit 2
