export CGO_ENABLED := 0

# Pinned and run through `go run`: no global install and nothing added to go.mod.
LINT := go run github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.15.0
VULN := go run golang.org/x/vuln/cmd/govulncheck@v1.9.0
# The generator ships with the usage-ledger plugin, not with this repository. Newest installed version.
LEDGER := python3 $(lastword $(sort $(wildcard $(HOME)/.claude/plugins/cache/dev-workflow-plugins/usage-ledger/*/skills/usage-ledger/scripts/ledger.py)))

# Packages that open sockets. net/url and net/netip are pure parsers (pulled in by bubbletea) and stay allowed.
NET_PACKAGES := ^(net|net/http(/.*)?|crypto/tls)$$

SHFMT := go run mvdan.cc/sh/v3/cmd/shfmt@v3.10.0
SHELL_FILES := $(shell git ls-files '*.sh' scripts/hooks)

check: fmt vet lint test vuln sizecheck nonet shell

fmt:
	@test -z "$$(gofmt -l .)" || { gofmt -l .; echo "fmt: run gofmt -w on the files above"; exit 1; }

vet:
	go vet ./...

lint:
	$(LINT) run

test:
	go test ./...

vuln:
	$(VULN) ./...

sizecheck:
	@scripts/sizecheck.sh

# Syntax and format always run. shellcheck is optional: skipped with a notice when not installed.
shell:
	@for f in $(SHELL_FILES); do bash -n $$f || exit 1; done
	@$(SHFMT) -d $(SHELL_FILES)
	@if command -v shellcheck >/dev/null; then shellcheck $(SHELL_FILES); else echo "shell: shellcheck not installed, skipped"; fi

nonet:
	@deps=$$(go list -deps ./cmd/clarivident) && { ! echo "$$deps" | grep -E '$(NET_PACKAGES)' || { echo "nonet: the binary must not link the packages above"; exit 1; }; }

# Phony because ledger/ is a directory: without this, make reports it as up to date.
.PHONY: ledger hook

ledger:
	@$(LEDGER) sync

# Points git at the versioned hooks, so the pre-commit check runs on every commit the user makes.
hook:
	@git config core.hooksPath scripts/hooks
