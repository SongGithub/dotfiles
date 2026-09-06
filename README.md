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

## Getting started
- install iTerm2 and follow [this doc](https://apple.stackexchange.com/questions/136928/using-alt-cmd-right-left-arrow-in-iterm) to customise.
- Clone source code `git clone git@github.com:songgithub/dotfiles.git ~/.dotfiles`
- Run setup script `./bootstrap.zsh`


## when you need to add a new RC file

- put the `*_rc` file into rc_files dir
- `cd` into `~/.dotfiles`, and run `~/bootstrap.zsh` in order to create a symlink for the new file.

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
