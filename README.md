# dotfiles


## Why you need this

- Setup a new __Mac__ with exactly same familiar settings in __one__ go.
- Keep installed software up to date.
- Ease of maintain your dotfiles: this even adopts programming concept of _separate-of-concern_


## What is this about:

Just a bunch of dotfiles

- zsh
- vim
- homebrew
- aliases
- ...

## Two setup paths

This repo currently has **two** ways to apply the same setup, side by side, while the declarative
one gets proven out:

| | `bootstrap.zsh` (original) | `flake.nix` (new) |
|---|---|---|
| Style | Imperative bash script | Declarative Nix (`nix-darwin` + `home-manager`) |
| Re-running | Hand-written `if`/`else` idempotency per tool | Idempotent by construction |
| Preview before applying | Not possible -- you find out from scrollback | `darwin-rebuild build` + `nix store diff-closures` |
| Undo | Single-slot `~/.dotfiles_backup` copy | `darwin-rebuild rollback` (real generations) |
| Status | Proven, currently in daily use | New, not yet applied on a real machine |

See [`specs/001-declarative-machine-setup/`](specs/001-declarative-machine-setup/) for the full
spec, the technical decisions behind the Nix path (`research.md`), and the file-by-file mapping
from the bash/rc_files version (`plan.md`, `data-model.md`).

### Getting started (`bootstrap.zsh`, original path)
- install iTerm2 and follow [this doc](https://apple.stackexchange.com/questions/136928/using-alt-cmd-right-left-arrow-in-iterm) to customise.
- Clone source code `git clone git@github.com:songgithub/dotfiles.git ~/.dotfiles`
- Run setup script `./bootstrap.zsh`

### Getting started (`flake.nix`, new declarative path)

One-time only, before anything else in this repo can be applied declaratively:

```bash
./install-nix.sh
```

Then, from a checkout of this repo:

```bash
sudo darwin-rebuild switch --flake .#mbp23
```

This single command replaces everything `bootstrap.zsh` does: shell (zsh + oh-my-zsh, aliases,
functions, exports), vim + vim-plug, the CLI tools it used to `brew install` (now real `nixpkgs`
packages), `specify-cli`, and the Sublime Text `subl` shim + update-check-nag fix. Homebrew is
kept, but only for `claude-code` (a GUI-adjacent cask) -- see `darwin/homebrew.nix`.

Before applying a change, preview it:

```bash
darwin-rebuild build --flake .#mbp23
nix store diff-closures /run/current-system ./result
```

To undo the most recent apply:

```bash
darwin-rebuild rollback
```

Full walkthrough with expected output at each step:
[`specs/001-declarative-machine-setup/quickstart.md`](specs/001-declarative-machine-setup/quickstart.md).

**Status**: the Nix files exist and are believed correct but have **not yet been applied** on a
real machine (this repo's checkout doesn't have Nix installed yet) -- treat the first
`darwin-rebuild switch` as the real validation step, not this document.

## when you need to add a new RC file

- **`bootstrap.zsh` path**: put the `*_rc` file into `rc_files/` dir, `cd` into `~/.dotfiles`, and
  run `~/bootstrap.zsh` in order to create a symlink for the new file.
- **`flake.nix` path**: `rc_files/*` are still the source of truth for shell content (see
  `home/shell.nix`, which sources them as plain files rather than re-declaring them in Nix) -- add
  your file there, then wire it into `home/shell.nix`'s `initExtra` the same way `.aliases`,
  `.functions`, and `.exports` already are.

## GitHub Spec Kit (`specify`)

`bootstrap.zsh` installs [Spec Kit](https://github.com/github/spec-kit) via `uv`,
so a fresh machine gets it for free. Three pieces have to line up:

1. `uv` is installed by Homebrew (it's in `software_list` in `bootstrap.zsh`).
2. `uv tool install specify-cli` puts the `specify` entrypoint in `~/.local/bin`.
3. `rc_files/exports` puts `~/.local/bin` on `PATH`.

Step 3 is the one that bites you. `uv` suggests running `uv tool update-shell`,
but that appends the export to `~/.zshenv`, which is **not** tracked by this repo
— so it silently doesn't follow you to the next computer. The `PATH` line lives
in `rc_files/exports` instead, which is symlinked to `~/.exports` and sourced by
`zshrc`. If you already ran `uv tool update-shell` on a machine, the duplicate
line in `~/.zshenv` is harmless and can be deleted.

### Manual install / repair

```bash
brew install uv
uv tool install specify-cli      # or: uv tool upgrade specify-cli
exec zsh                         # pick up ~/.exports
specify check                    # verify tooling + list agent integrations
```

If you hit `zsh: command not found: specify`, `PATH` is the problem, not the
install — check `ls ~/.local/bin/specify` and that `~/.exports` is sourced.

### Configuring a project

Spec Kit is scaffolded per repo, not globally:

```bash
cd ~/workspaces/some-project
specify init . --integration claude     # scaffold into an existing repo
specify init my-new-project             # or scaffold a new directory
```

Useful flags: `--force` to skip the confirmation when the directory isn't empty,
`--non-interactive` for scripted/agent runs, `--integration` to pick the coding
agent (`claude`, `copilot`, `gemini`, …; `specify check` lists them).

Housekeeping: `specify self upgrade` updates the CLI, and `uv tool list` shows
what's installed. An `environment not found` warning there means a stale tool —
reinstall it with `uv tool install <name> --reinstall`.

## Assumptions:
- you are using a Mac ( having curl preinstalled ). Skip Mac specific steps if on a Linux.
- you have installed Sublime Text 3.

## Reference

[Gus's dotfile](https://github.com/gugahoi/dotfiles)
