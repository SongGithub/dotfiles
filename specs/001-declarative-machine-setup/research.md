# Phase 0 Research: Declarative Machine Setup

Each open question from the Technical Context, resolved.

## Nix installer

**Decision**: Determinate Systems' `nix-installer` (`curl -fsSL https://install.determinate.systems/nix | sh -s -- install`).

**Rationale**: This is the one unavoidable manually-triggered, imperative step (FR-008 /
Edge Cases in the spec) — a chicken-and-egg problem, since Nix itself has to exist before
anything declarative can run. The Determinate installer enables flakes + the `nix-command`
experimental feature by default (the official installer requires a manual `nix.conf` edit
afterward), and ships a real uninstaller (`/nix/nix-installer uninstall`) — directly relevant
after this session's experience clawing back a broken `/opt/homebrew` ownership and a stale
`/usr/local` Homebrew prefix. A bad Nix install should not become the same kind of multi-year
leftover.

**Alternatives considered**: Official `nixos.org` install script (more "canonical" but requires
a manual flakes opt-in step, and its multi-user daemon uninstall is a documented manual, multi-file
process); `nix-darwin`'s own bundled installer flow (works, but it's really just wrapping one of
the two above).

## Flakes vs. channels

**Decision**: Flakes (`flake.nix` + `flake.lock`), not the classic `nix-channel` model.

**Rationale**: `flake.lock` pins exact input revisions the same way `Gemfile.lock`/`package-lock.json`
do — reproducible by default, and the change is visible/reviewable as a diff in this git repo
(consistent with FR-003's preview requirement). Channels are mutable, host-wide, and drift silently
between machines, which is the exact "silent divergence" failure mode this migration exists to remove.

**Alternatives considered**: Classic channels (simpler mental model, but no lockfile — rejected,
directly conflicts with FR-002/FR-003).

## System + user config wiring

**Decision**: `home-manager` runs as a `nix-darwin` module (`home-manager.darwinModules.home-manager`
imported into the same flake), not invoked standalone via `home-manager switch`.

**Rationale**: The spec's User Story 1 requires *one* command to reach full parity
(`darwin-rebuild switch`). Standalone home-manager would mean two separate tools with two separate
generation histories to keep in sync — reintroducing exactly the kind of "did I remember both
steps" manual coordination this migration is meant to eliminate.

**Alternatives considered**: Standalone home-manager + separate nix-darwin, run independently
(more decoupled, matches how some multi-user/shared-machine setups do it — rejected here as
unnecessary complexity for a single personal user, and it fails FR-001's "single command" bar).

## What stays on Homebrew

**Decision**: Only GUI `.app`-bundle software with no meaningful Nix packaging path — concretely,
Sublime Text — stays declared via `nix-darwin`'s `homebrew.casks` list. Every CLI tool currently
in `bootstrap.zsh`'s `software_list` (`gcc`, `bash`, `tig`, `icdiff`, `vim`, `zsh-syntax-highlighting`,
`zsh-autosuggestions`, `python`, `kubectx`, `watch`, `uv`) plus the tools installed ad hoc this
session (`gh`, `kubectl`/`kubernetes-cli`, `go`, `minikube`, `protobuf`, `tree`, `ffmpeg`, `gdbm`,
`perl`) all have `nixpkgs` packages and move to `home.packages` / `environment.systemPackages`.

**Rationale**: Directly resolves this session's root-cause bug class (stale `/usr/local`
Intel-Homebrew binaries silently shadowing arm64 ones on `$PATH`) by shrinking Homebrew's footprint
to a short, explicit, rarely-touched list — fewer packages on the legacy path means fewer chances
for a second parallel install to ever accumulate again. It also satisfies FR-007 (GUI apps stay
declared in the same configuration) without pretending Nix can install `.app` bundles itself.

**Alternatives considered**: Drop Homebrew entirely, install Sublime Text manually outside the
declared config (rejected — violates FR-007, would silently regress a capability the current
script already has: linking the `subl` CLI shim).

## Rollback mechanism

**Decision**: `darwin-rebuild rollback` (steps back one applied generation) for the common case;
`darwin-rebuild switch --flake .#<host>` against an older pinned git commit for anything further back.

**Rationale**: `nix-darwin` keeps every activated configuration as a numbered generation under
`/nix/var/nix/profiles/system`, with `/run/current-system` symlinked to the active one. This is a
structural answer to FR-004/FR-005 and directly replaces the single-slot `~/.dotfiles_backup`
folder, whose failure mode (a second bad run silently overwrites the only backup of the first) is
explicitly called out in the spec's User Story 3.

**Alternatives considered**: Keep a manual backup-copy convention as a belt-and-suspenders fallback
(rejected as unnecessary — it's the exact pattern being replaced, and generations already provide
strictly stronger guarantees).

## Preview mechanism

**Decision**: `darwin-rebuild build --flake .` (builds the new system closure without activating
it) followed by `nix store diff-closures /run/current-system ./result` to see exactly what
packages/versions would change, before running `darwin-rebuild switch`.

**Rationale**: This is the closest real equivalent to `terraform plan` in the Nix ecosystem and
satisfies FR-003. It should be stated plainly that this is a **package/derivation-level** diff
(what changes in the Nix store), not a human-narrated "setting X changes from A to B" — a real
gap relative to tools like Terraform, worth knowing going in rather than discovering later.

**Alternatives considered**: `darwin-rebuild check` alone (only validates the config evaluates,
doesn't show a diff — insufficient for FR-003 on its own, but still useful as a fast pre-check).
