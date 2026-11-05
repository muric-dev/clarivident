# Clarivident

A read-only terminal app for macOS that answers two questions: what is eating my disk, and why did I have 40 GB free yesterday and 200 MB today?

> Early days. The MVP below is the plan, not what ships today.

### Features (MVP)
- Prints one clean report of your disk: capacity, used, free and purgeable.
- Splits the disk by APFS volume (Data, System, VM, Preboot...).
- Groups what lives in Data by category: Dev, Applications, Caches, Photos, Documents...
- Closes the math. Whatever it can't measure shows up as its own row, so the numbers always add up.
- Tells you when it has no access to a folder instead of guessing.

### What the report looks like

Numbers are made up. The shape is real.

```text
Disk        228.3 GiB · used 219.5 · free 8.8 · purgeable 0.1

Volumes
  Data        185.9 GiB
  System       12.8 GiB
  VM           10.0 GiB
  Preboot       9.1 GiB
  Recovery      1.4 GiB
  Update        0.1 GiB
  Unassigned    0.2 GiB

Data by category
  Dev               62.1 GiB   27 %
  Applications      35.5 GiB   16 %
  macOS             30.3 GiB   13 %
  Photos            12.0 GiB    5 %
  Caches             9.4 GiB    4 %
  Documents          7.2 GiB    3 %
  Other             12.6 GiB    6 %
  No access         791 folders · enable Full Disk Access to measure them
  Unaccounted       16.8 GiB    7 %
```

### Requirements
- macOS 27.x (tested on 27.2)
- Go 1.26+ to build it
- Full Disk Access for your terminal if you want Mail, Messages, iCloud and Trash included

### Usage

```bash
go run ./cmd/clarivident
```

The `report` command is what the first release is about:

```bash
clarivident report
```

### Why read-only?
- **Safe by design**: it only reads metadata (`lstat` and `readdir`). It never deletes, moves or opens your files.
- **Offline**: no network, no telemetry. The binary doesn't even link the `net` package, and `make check` verifies it.
- **Your call**: it can tell you what is regenerable, but you decide what to do with it.

### Not in the MVP
- Deleting or cleaning anything.
- Timeline of "why did it change" (comes after the report, with an encrypted local vault).
- Other macOS versions, Linux, Windows or a GUI.

### Development

```bash
make check   # fmt, vet, lint, test, vuln, size budgets and the no-net check
```
