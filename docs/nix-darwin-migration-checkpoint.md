# Checkpoint: nix-darwin/home-manager migration

**Date**: 2026-09-10
**Branch**: `explore/nix-darwin-migration`
**Spec**: [`specs/001-declarative-machine-setup/`](../specs/001-declarative-machine-setup/)

Snapshot of where this migration actually stands, on the real machine, as of this commit --
separate from the spec/plan/research docs, which describe the design rather than live status.

## Done

- **Spec + plan** written via Spec Kit (`spec.md`, `plan.md`, `research.md`, `data-model.md`,
  `contracts/cli.md`, `quickstart.md`).
- **Like-for-like Nix port written**: `flake.nix`, `darwin/configuration.nix`,
  `darwin/homebrew.nix`, `home/*.nix` -- a faithful port of `bootstrap.zsh` + `rc_files/`, not a
  redesign (see `plan.md` for the file-by-file mapping).
- **`install-nix.sh` added** as its own idempotent script (not folded into `bootstrap.zsh` --
  see its header comment for why).
- **Disk space cleared** on this machine: was 9.6GB free (98.1% of the container in use), now
  27.9GB free, via:
  - Deleting one purgeable APFS local snapshot on the Data volume (`+11.3GB`) -- NOT the three
    `com.apple.os.update-*` snapshots on the System volume, which are non-purgeable and one of
    which is the live boot snapshot; those were correctly left alone.
  - Uninstalling the stale, fully-shadowed Intel Homebrew prefix at `/usr/local` via Homebrew's
    official uninstaller with an explicit `--path=/usr/local` (its default target on Apple
    Silicon is `/opt/homebrew` -- the *active* install -- so the explicit path was required)
    (`+7GB`).
  - The remaining large consumer of disk space on this machine is a separate macOS user account
    (`/Users/song`, ~317GB of real Photos/Music/Movies/Dropbox/Google Drive data) -- confirmed
    to be genuine data, not reclaimable, and deliberately left untouched.
- **Nix installed** via `./install-nix.sh` (Determinate Nix 3.22.3).
- **`nix flake check` passes** on the first attempt -- no eval errors, all module options
  resolved correctly against the pinned `nix-darwin`/`home-manager`/`nixpkgs` revisions.
- **`flake.lock` generated and committed.**

## In progress / next

- `nix build .#darwinConfigurations.mbp23.system` -- builds the full system closure without
  activating anything (no sudo required). This is the next real test: whether every declared
  package (`go`, `ffmpeg`, `gcc`, `protobuf`, `minikube`, etc.) actually resolves and fetches.
- First activation (**not yet run** -- this is the one step that changes the live system):
  ```sh
  nix run nix-darwin -- switch --flake .#mbp23
  ```
  `darwin-rebuild` doesn't exist on `PATH` until after this first run; subsequent applies use the
  plain `darwin-rebuild switch --flake .#mbp23` documented in `README.md`/`quickstart.md`.
- After a successful first switch: verify against `quickstart.md`'s scenarios (shell/tools resolve
  under Nix or the declared Homebrew cask, `subl` shim works, vim-plug installs, etc.).

## Known open items, not yet resolved

- PR #3 (`fix/bootstrap-arm64-shadowing`, the `bootstrap.zsh` fixes) is still open/unmerged
  upstream. This branch already contains those commits (merged in early on, to port from the
  *current* fixed bash source rather than the stale pre-fix one) -- so a PR from this branch will
  show PR #3's commits too until #3 merges. That's expected, not a mistake.
- `bootstrap.zsh` and `rc_files/*` are left in place, unchanged, as the proven fallback. No
  decision has been made yet to retire them -- that's contingent on the Nix path actually working
  end-to-end on this machine.
