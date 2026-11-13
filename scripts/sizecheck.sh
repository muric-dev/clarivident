#!/bin/sh
# Size budgets for Go and agent files. Function length is covered by funlen.
# Agent files have their own budget: every line is read on each session or skill run.
# BASE overrides the branch a PR is measured against.
set -eu

max_file=500
max_project=5000
max_agent=100
max_pr=200
base=${BASE:-main}
status=0

fail() {
	echo "sizecheck: $1" >&2
	status=1
}

for f in CLAUDE.md .claude/skills/*/SKILL.md .claude/agents/*.md .claude/rules/*.md; do
	[ -f "$f" ] || continue
	n=$(($(wc -l <"$f")))
	[ "$n" -le "$max_agent" ] || fail "$f has $n lines, agent file limit $max_agent"
done

project=0
for f in $(git ls-files --cached --others --exclude-standard -- '*.go' | sort -u); do
	[ -f "$f" ] || continue
	n=$(($(wc -l <"$f")))
	[ "$n" -le "$max_file" ] || fail "$f has $n lines, limit $max_file"
	case "$f" in
	*_test.go | *testdata/*) ;;
	*) project=$((project + n)) ;;
	esac
done

# Net production lines since the branch left base. Before base exists, all of them.
pr=$project
if since=$(git merge-base "$base" HEAD 2>/dev/null); then
	production="-- *.go :!*_test.go :!*testdata/*"
	set -f
	tracked=$(git diff --numstat "$since" $production | awk '{ n += $1 - $2 } END { print n + 0 }')
	new=$(git ls-files --others --exclude-standard $production | xargs cat | wc -l)
	set +f
	pr=$((tracked + new))
fi

[ "$project" -le "$max_project" ] || fail "project has $project production lines, review at $max_project"
[ "$pr" -le "$max_pr" ] || fail "PR has $pr net production lines, limit $max_pr"
[ "$status" -ne 0 ] || echo "sizecheck: $pr net production lines in this PR, $project in the project"
exit "$status"
