# CLI Contract: Declarative Machine Setup

This project's "interface" is the set of commands a human runs against the flake — there is no
API/network surface. Each command's inputs, outputs, and side effects are documented here so
`quickstart.md` can reference them instead of restating them.

## `darwin-rebuild check --flake .`

- **Purpose**: Validate the Declared Configuration evaluates without building or activating anything.
- **Side effects**: None on the running machine.
- **Maps to spec**: Fast pre-check before FR-003's preview step.

## `darwin-rebuild build --flake .`

- **Purpose**: Build the full system closure for the current Declared Configuration without
  switching to it.
- **Output**: A `./result` symlink pointing at the built (but not yet active) closure.
- **Side effects**: Populates the Nix store with the new closure; does not touch
  `/run/current-system` or create a new Generation.
- **Maps to spec**: First half of FR-003 (preview before apply).

## `nix store diff-closures /run/current-system ./result`

- **Purpose**: Show the package/version-level diff between the currently active Generation and
  the just-built one.
- **Output**: Text diff of added/removed/changed store paths (packages), to stdout.
- **Maps to spec**: Second half of FR-003. Note the caveat from `research.md`: this is a
  derivation-level diff, not a narrated list of setting changes.

## `darwin-rebuild switch --flake .`

- **Purpose**: Build (if needed) and activate the Declared Configuration as the new Generation.
- **Side effects**: Creates a new Generation, updates `/run/current-system`, runs activation
  scripts (macOS defaults, Homebrew cask installs/upgrades, home-manager user profile activation).
- **Maps to spec**: FR-001 (fresh-machine setup), FR-002 (safe re-run — a no-op diff yields a
  no-op switch), SC-001, SC-002.

## `darwin-rebuild rollback`

- **Purpose**: Activate the Generation immediately prior to the current one.
- **Side effects**: Same activation side effects as `switch`, but targeting the prior Generation's
  closure; does not require the Declared Configuration files themselves to still be in that prior
  state on disk.
- **Maps to spec**: FR-004, FR-005, User Story 3, SC-004.

## `darwin-rebuild --list-generations`

- **Purpose**: List all retained Generations with their numbers and build dates, to pick a
  specific one to roll back to (beyond just "one step back").
- **Side effects**: None (read-only).
- **Maps to spec**: Supports FR-004 when the needed rollback is more than one step back.
