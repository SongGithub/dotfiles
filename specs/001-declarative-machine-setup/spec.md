# Feature Specification: Declarative Machine Setup

**Feature Branch**: `explore/nix-darwin-migration`

**Created**: 2026-09-10

**Status**: Draft

**Input**: User description: "Migrate this personal dotfiles/bootstrap repo from an imperative bash bootstrap.zsh script to a declarative macOS machine setup using nix-darwin (system-level: Homebrew casks/taps, macOS defaults, system packages) and home-manager (user-level: shell rc files currently in rc_files/, vim config, CLI tool packages). Goal: `darwin-rebuild switch` replaces running bootstrap.zsh, with generations/rollback replacing the current ~/.dotfiles_backup single-slot backup approach. GUI-only apps (e.g. Sublime Text) stay managed via nix-darwin's homebrew module (casks) since they aren't Nix-native on macOS. This is an exploratory sketch/spec for a single personal machine, not a team rollout."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Reproduce this machine's setup from a clean state (Priority: P1)

As the owner of this dotfiles repo, when I get a new Mac or wipe this one, I want to run a single command that brings the machine to my full personal configuration (shell, editor, CLI tools, GUI apps, macOS preferences) so I don't have to remember or re-derive any manual steps.

**Why this priority**: This is the entire reason the original 2017 bootstrap script exists. Any replacement must do at least this or it's a regression, not an upgrade.

**Independent Test**: On a fresh macOS user account (or a fresh VM), run the setup command with no other manual steps, then verify shell, editor, and CLI tools all match what's declared in the repo.

**Acceptance Scenarios**:

1. **Given** a brand-new Mac with only Xcode Command Line Tools present, **When** I run the setup command, **Then** my shell, editor, CLI tools, and declared macOS preferences all end up matching what's declared in the repo, with no further manual steps.
2. **Given** a machine that already has the setup applied, **When** I run the setup command again with no changes to the repo, **Then** nothing changes and no errors occur (re-running is always safe).

---

### User Story 2 - Change my setup and know exactly what will change before it happens (Priority: P1)

As the owner of this repo, when I edit my declared configuration (add a tool, change a shell setting, adjust a macOS preference), I want to see a preview of exactly what will change on my actual machine before I apply it, so I don't get surprised by unintended side effects.

**Why this priority**: The current bash script has no preview step — you only find out what happened by reading scrollback after the fact, or from silent, hand-written idempotency checks that may not cover every case. A declarative approach's core value proposition is a computable diff between "declared" and "current."

**Independent Test**: Change one setting in the repo (e.g. add a CLI package), run the "preview" step, and verify it names exactly that one change with nothing else listed.

**Acceptance Scenarios**:

1. **Given** a one-line change to the declared configuration, **When** I preview the change, **Then** the preview lists only that change and nothing unrelated.
2. **Given** no changes to the declared configuration, **When** I preview, **Then** the preview reports no changes.

---

### User Story 3 - Undo a bad change without manual cleanup (Priority: P2)

As the owner of this repo, when a setup change breaks something (a tool stops working, a shell setting misbehaves), I want to roll back to the exact previous working state in one step, without hunting through a manually-maintained backup folder.

**Why this priority**: The current script's only safety net is copying overwritten files into `~/.dotfiles_backup`, one slot per filename — a second bad run silently clobbers the only backup of the first. This is a known weak point, not a hypothetical one.

**Independent Test**: Apply a change, confirm it's live, then roll back and confirm the machine matches the prior state exactly (including files that were deleted or replaced by the change).

**Acceptance Scenarios**:

1. **Given** a change has been applied, **When** I invoke the rollback step, **Then** the machine returns to the prior declared state without me having to manually restore any file.
2. **Given** two changes have been applied in sequence, **When** I roll back once, **Then** I land on the state from immediately before the most recent change (not further back), and can roll back again to go further.

---

### User Story 4 - Keep using a GUI app that isn't natively packaged (Priority: P3)

As the owner of this repo, I want GUI-only applications (e.g. my licensed Sublime Text install) to keep working and stay declared in the same setup, even though they aren't distributed in a way the declarative package system can fully manage.

**Why this priority**: Lower priority than the core reproducibility/preview/rollback stories because it affects a small, known set of apps rather than the whole machine, but it must not be dropped or the migration loses functionality the current script already has (it links the `subl` CLI shim today).

**Independent Test**: Fresh-machine run installs the GUI app and its CLI shim without any manual App Store or drag-and-drop step, and the app is listed in the same declared configuration as everything else.

**Acceptance Scenarios**:

1. **Given** the GUI app is declared in the setup, **When** I run the setup command on a machine that doesn't have it, **Then** the app and its command-line shim are both present afterward.
2. **Given** the GUI app is already installed and up to date, **When** I run the setup command again, **Then** it is left alone (no forced reinstall or update prompt triggered by the setup tool itself).

### Edge Cases

- What happens when the declarative tooling itself isn't installed yet on a completely fresh machine (chicken-and-egg bootstrap step)?
- How does the system handle a declared package that has no equivalent in the declarative package system's repository (must fall back to some other install path, e.g. GUI-app case above)?
- How does the system handle two shells being open at apply-time — does an in-progress apply affect an already-running shell session, or only new ones?
- What happens if the machine has manual, undeclared changes made outside the setup tool (drift) — are they silently overwritten, preserved, or flagged?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The setup MUST be re-runnable from a single command against a freshly-imaged Mac with no other manual configuration and produce a fully working environment (shell, editor, CLI tools, declared macOS preferences, declared GUI apps).
- **FR-002**: The setup MUST be safe to re-run against a machine that's already fully configured, making no changes and reporting no errors.
- **FR-003**: Applying a declared change MUST be preceded by a preview step that reports exactly what will change, before anything is changed.
- **FR-004**: The setup MUST record enough history that a prior applied state can be restored in one step, without depending on any hand-maintained backup copy of overwritten files.
- **FR-005**: Rolling back MUST restore the machine to the exact prior declared state, including files or packages that the rolled-back change had removed or replaced.
- **FR-006**: The declared configuration MUST cover both system-level state (macOS preferences, system-wide packages) and user-level state (shell configuration, editor configuration, per-user CLI tools) as a single source of truth checked into this repo.
- **FR-007**: GUI-only applications that cannot be fully managed by the declarative package system MUST still be declared in the same configuration and installed by the same setup command, including any CLI shims they need (e.g. `subl`).
- **FR-008**: The one-time bootstrap step required to get the declarative tooling itself onto a fresh machine MUST be documented and MUST be the only manually-triggered step in the whole setup process.
- **FR-009**: The migration MUST NOT silently drop any capability the current `bootstrap.zsh` provides (see Assumptions for the enumerated current capabilities) without an explicit, documented decision to drop it.

### Key Entities

- **Declared Configuration**: The checked-in, version-controlled description of the desired end state of the machine — supersedes `bootstrap.zsh` + `rc_files/` as the source of truth.
- **Generation / Applied State**: A specific, ordered, restorable snapshot of the declared configuration that has been applied to the machine. Rollback operates on this history.
- **GUI-only Application**: An application (e.g. Sublime Text) that must be present on the machine but is not fully installable/upgradable through the declarative package system, requiring a documented exception path.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A fresh Mac reaches full working parity with this machine's current setup via one command, start to finish, with zero manual steps beyond the one-time tooling bootstrap.
- **SC-002**: Re-running the setup command on an already-configured, unchanged machine completes with zero reported changes and zero errors, every time.
- **SC-003**: 100% of declared changes are previewable before being applied — there is no path to changing machine state without a prior preview step being available.
- **SC-004**: Rolling back the most recent change takes one command and requires no manual file restoration, verified across at least 3 consecutive rollback/reapply cycles with no accumulated drift.
- **SC-005**: All capabilities present in the current `bootstrap.zsh` (enumerated in Assumptions) are verified present after migration, with any intentionally-dropped capability explicitly documented rather than silently missing.

## Assumptions

- This is a single personal machine, not a fleet — multi-machine consistency and team onboarding are explicitly out of scope for this spec.
- The current `bootstrap.zsh` capabilities that must be preserved unless explicitly dropped: shell (zsh + oh-my-zsh) setup, rc file linking (`aliases`, `exports`, `functions`, `vimrc`, `zshrc`), Homebrew system package installation, the `claude-code` CLI, `uv`-installed tools (`specify-cli`), vim + vim-plug plugin installation, the Sublime Text `subl` CLI shim, and the one Sublime Text preferences tweak (disabling the update-check nag).
- "Declarative tooling" bootstrap (installing the tool that will manage everything else) is accepted as the one unavoidable imperative, manually-triggered step — see Edge Cases.
- Rollback granularity is "whole-machine, per-apply" (an applied change and everything in it), not per-individual-file — matching how the eventual chosen tooling models state.
- GUI applications distributed only as `.app` bundles (not through a package format the declarative system can manage directly) are handled via a documented fallback path rather than blocking the whole migration.
- No secrets or credentials are part of this setup's scope; anything security-sensitive continues to be handled outside this repo as it is today.
