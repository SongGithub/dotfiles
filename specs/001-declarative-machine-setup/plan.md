# Implementation Plan: Declarative Machine Setup

**Branch**: `explore/nix-darwin-migration` | **Date**: 2026-09-10 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-declarative-machine-setup/spec.md`

## Summary

Replace `bootstrap.zsh` + `rc_files/*` with a single Nix flake that drives both system-level
setup (`nix-darwin`) and user-level setup (`home-manager`, run as a `nix-darwin` module so one
`darwin-rebuild switch` applies both). Homebrew is kept only for the handful of things Nix can't
own on macOS — GUI `.app` bundles like Sublime Text — everything else currently installed via
`brew` in `bootstrap.zsh`'s `software_list` (gcc, tig, icdiff, vim, uv, gh, kubectl, go, minikube,
protobuf, tree, ffmpeg, gdbm, perl, etc.) is already packaged in `nixpkgs` and moves to Nix outright.

## Technical Context

**Language/Version**: Nix expression language (via `nix-darwin` + `home-manager`, both tracking
`nixpkgs-unstable` or a pinned stable channel)

**Primary Dependencies**: `nix-darwin`, `home-manager` (as a `nix-darwin` module, not standalone),
`nixpkgs`, Homebrew (kept, scoped down to GUI casks only, itself declared via `nix-darwin`'s
`homebrew` module rather than run ad hoc)

**Storage**: N/A — configuration is files in this git repo; runtime state is Nix's own store/profile
generations under `/nix` and `/run/current-system`, not a database

**Testing**: `darwin-rebuild check` (config evaluates) and the `quickstart.md` scenarios (manual,
since this is a machine-setup tool, not an application with a unit test suite)

**Target Platform**: macOS, Apple Silicon (arm64) — this repo has already established it does not
support Intel Macs (see `bootstrap.zsh`'s existing Rosetta guard)

**Project Type**: Single-machine personal infrastructure-as-code repo (not a library, service, or app)

**Performance Goals**: N/A in the traditional sense; qualitative goal is "`darwin-rebuild switch`
completes in a normal `brew`-comparable timeframe using cached/substituted binaries, not full
from-source rebuilds"

**Constraints**: Must not require a second machine or CI to bootstrap (single-laptop, offline-capable
after initial fetch); must not regress any capability listed in the spec's Assumptions section

**Scale/Scope**: One personal machine. Multi-machine/team use is explicitly out of scope (per spec).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

`.specify/memory/constitution.md` is still the unfilled template (no `/speckit-constitution` has
been run in this repo) — there are no project-specific principles or gates to check against. No
gate failures to report; nothing to justify in Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/001-declarative-machine-setup/
├── plan.md              # This file
├── research.md           # Phase 0 output
├── data-model.md         # Phase 1 output
├── quickstart.md         # Phase 1 output
├── contracts/
│   └── cli.md            # Phase 1 output — the commands this setup exposes
└── tasks.md              # Phase 2 output (/speckit-tasks — not created by this command)
```

### Source Code (repository root)

**Structure Decision**: Single Nix flake at the repo root, replacing `bootstrap.zsh` and
`rc_files/` in place. Existing non-Nix assets (`patches/`, `README.md`) stay as-is; `patches/` is
referenced from the home-manager module instead of `cp` in a bash script.

```text
flake.nix                     # Entry point: darwin + home-manager configurations, pinned inputs
flake.lock                    # Reproducible pin of nixpkgs/nix-darwin/home-manager revisions

darwin/
├── configuration.nix         # System-level: macOS defaults, system packages, primaryUser
└── homebrew.nix              # homebrew.casks list (Sublime Text, etc.) + taps, no unmanaged brews

home/
├── home.nix                  # Entry point for the user profile; imports the modules below
├── shell.nix                  # zsh + oh-my-zsh equivalent, replaces rc_files/zshrc
├── aliases.nix                 # replaces rc_files/aliases
├── exports.nix                  # replaces rc_files/exports (PATH, EDITOR, etc.)
├── functions.nix                 # replaces rc_files/functions
├── vim.nix                        # replaces rc_files/vimrc + vim-plug plugin list
├── git.nix                         # net-new: git config as data instead of left to global git config
└── packages.nix                     # the software_list CLI tools, as a plain package list

patches/
└── minimap_settings.py        # unchanged; home.nix places it via `home.file`

README.md                      # updated to describe `darwin-rebuild switch` as the new entrypoint
```

## Complexity Tracking

*No Constitution Check violations — this section intentionally left empty.*
