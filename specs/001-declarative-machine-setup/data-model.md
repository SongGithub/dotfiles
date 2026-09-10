# Phase 1 Data Model: Declarative Machine Setup

This is a machine-configuration project, so "entities" are the conceptual objects the Nix
configuration manipulates, not application data.

## Declared Configuration

The checked-in, version-controlled description of the desired end state. Concretely: `flake.nix`
plus everything it imports from `darwin/` and `home/`.

- **Fields**: `flake.lock` (pinned input revisions), `darwin/configuration.nix` (system state),
  `darwin/homebrew.nix` (cask exceptions), `home/*.nix` (user state).
- **Relationships**: One `Declared Configuration` produces exactly one `Generation` per apply.
- **Validation rules**: Must evaluate cleanly under `darwin-rebuild check` before it can be applied
  (FR-001, FR-002). Every declared package/setting must trace to a requirement in `spec.md`'s
  Assumptions list, or be an explicitly-noted addition.

## Generation / Applied State

A specific, numbered, restorable snapshot of the Declared Configuration that has been activated on
the machine, managed by `nix-darwin`/Nix itself (not custom code).

- **Fields**: generation number, activation timestamp, the store path it points at
  (`/run/current-system`), the git commit of this repo it was built from (recommended convention:
  tag or note the commit SHA in the generation's description where `nix-darwin` supports it).
- **Relationships**: Generations form a linear history; `darwin-rebuild rollback` moves the
  "current" pointer to the immediately-prior Generation. Each Generation was produced by exactly
  one Declared Configuration.
- **State transitions**: `(build)` → built-but-not-active closure → `(switch)` → active Generation
  → superseded by the next `(switch)`, or restored via `(rollback)`.
- **Validation rules**: Rollback must be possible without any file the rolled-back change touched
  being manually restored (FR-005) — this is a property of using Nix's store/profile mechanism
  rather than in-place file edits, not something this repo has to implement itself.

## GUI-only Application

An application that must be present on the machine but isn't (fully) installable through the Nix
package manager on macOS — tracked explicitly rather than silently handled outside the config.

- **Fields**: name, Homebrew cask identifier, any CLI shim it needs linked (e.g. `subl`), whether
  it needs a license (informational note only, not enforced by tooling).
- **Relationships**: Declared inside `darwin/homebrew.nix`'s cask list, which is itself part of the
  Declared Configuration — so it's covered by the same apply/preview/rollback lifecycle as
  everything else (FR-007), even though the underlying install mechanism (Homebrew) differs.
- **Validation rules**: A tool only belongs on this list if it has no viable `nixpkgs` package —
  otherwise it belongs in `home/packages.nix` instead. (Current known instance: Sublime Text.)
