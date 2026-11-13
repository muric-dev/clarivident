---
paths:
  - "internal/tui/**"
---

# TUI rules

## Libraries
- Only these UI libraries: `charm.land/bubbletea/v2` (loop), `charm.land/lipgloss/v2` (style, layout), `charm.land/bubbles/v2` (components). Anything else needs human approval.
- Use `table`, `viewport`, `progress`, `help`, `key`, `spinner`. Never `bubbles/list` or `textinput`: they link `atotto/clipboard`, which runs `pbcopy`/`pbpaste` through os/exec, and this program runs no commands outside `internal/platform`.
- No chart dependency. Bars come from `bubbles/progress` or lipgloss, wrapped once in a widget.

## Layers (dependencies point down only)
```
cmd/clarivident        wires real services into the app (the only place that knows both sides)
internal/tui           root model: tabs, routing, window size, global keys. Defines the Page contract.
internal/tui/<page>    one package per page: its model, its page-only widgets (unexported), its data contract
internal/tui/widget    reusable widgets, shared by two or more pages
internal/tui/theme     colors and lipgloss styles. A leaf: imports nothing of ours.
internal/<domain>      scan, classify, history...: no tui import, ever
```
- A page never imports another page. A widget never imports a page. `theme` imports nothing of ours. Domain packages never import `tui`.
- A widget starts inside the page that needs it, unexported. Move it to `internal/tui/widget` when a second page needs it, not before.
- Start flat. Split into the packages above when the second page appears, not as scaffolding.

## Contracts (Go style: small interfaces, defined by the consumer)
- Page contract, in `internal/tui`: `Init() tea.Cmd`, `Update(tea.Msg) (Page, tea.Cmd)`, `View(width, height int) string`, `Title() string`. The root model knows only this.
- Data contract: each page declares the interface it needs in its own package, for example `type Usage interface { Usage(ctx context.Context) ([]Row, error) }`. Domain services satisfy it implicitly. The page never sees a concrete service, a path walker, or the vault.
- Widget contract: a widget takes plain props (a struct or arguments) and returns a string, or has the same `Update`/`View` shape when it holds state. It knows nothing about services, pages, or messages it did not define.
- Pages and widgets receive dependencies through constructors, never globals.

## Waiting for values
- All I/O runs in a `tea.Cmd` built from the page's data contract and comes back as a message. `Update` and `View` stay free of I/O so they are testable without a terminal.
- Each loadable value is modeled with an explicit state: loading, ready, unavailable, denied. `View` renders every state. A value that is still loading shows a spinner or placeholder, never a 0.
- Never show an invented 0: an unavailable metric says so, denied paths are a visible row, and the unaccounted row is always shown.
- Cancel with the context passed into the Cmd. A new request for the same page replaces the old one, and a stale message is dropped by comparing a request id.

## Behavior
- One scan, one reusable table. A view is a `GroupBy` over classify labels, never its own walk or table widget.
- Read-only: no action deletes or cleans anything. The UI marks what is regenerable and the user decides.

## Tests
- Test our behavior, not the library's rendering. Use fakes for the data contract, drive the page with messages, and assert on state and on text that View must contain (row labels, "unavailable", the denied row, the unaccounted row, the loading placeholder).
- Do not assert colors, borders, or exact layout. No golden files.
- Widgets: test the props-to-string rule in isolation (for example a 0-byte row is not hidden).
