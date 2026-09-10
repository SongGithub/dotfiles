# Quickstart: Validating the Declarative Machine Setup

Prerequisites: this repo checked out locally; nothing else (the one-time Nix bootstrap is step 1).

## 1. Bootstrap Nix (one-time, imperative — see `research.md`)

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Expected outcome: `nix` and `darwin-rebuild` are on `PATH` in a new shell.

## 2. First apply on a fresh machine (User Story 1 / SC-001)

```sh
cd dotfiles
sudo darwin-rebuild switch --flake .
```

Expected outcome: shell, editor, declared CLI tools, and declared macOS defaults all match this
repo, with no other manual step taken. Verify with the same kind of spot-check used earlier this
session, e.g.:

```sh
zsh -ilc 'command -v vim gh tig uv kubectl go ffmpeg; file $(command -v vim)'
```

All should resolve under the Nix store (or `/opt/homebrew` for the Homebrew-declared cask shim),
never a stray `/usr/local` path.

## 3. Re-apply with no changes (User Story 1 / SC-002)

```sh
darwin-rebuild switch --flake .
```

Expected outcome: reports no changes, exits cleanly, no errors.

## 4. Preview a change before applying (User Story 2 / SC-003)

```sh
# edit home/packages.nix: add one package
darwin-rebuild build --flake .
nix store diff-closures /run/current-system ./result
```

Expected outcome: the diff names exactly the one added package and nothing else. Only after
reviewing this do you run `darwin-rebuild switch --flake .` to apply it.

## 5. Roll back (User Story 3 / SC-004)

```sh
darwin-rebuild rollback
```

Expected outcome: machine returns to the immediately-prior Generation with no manual file
restoration. Repeat apply → rollback 3 times in a row (per SC-004) and confirm each cycle returns
to the same prior state with no accumulated drift.

## 6. GUI app still present and declared (User Story 4)

```sh
zsh -ilc 'command -v subl; file $(command -v subl)'
```

Expected outcome: `subl` resolves and launches Sublime Text, and `Sublime Text` appears in
`darwin/homebrew.nix`'s cask list — not installed by some undeclared manual step.

## Reference

See [`contracts/cli.md`](./contracts/cli.md) for what each command does and which requirement it
satisfies, and [`data-model.md`](./data-model.md) for what a "Generation" and "GUI-only
Application" mean in this context.
