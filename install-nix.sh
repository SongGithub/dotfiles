#!/bin/bash
# One-time, imperative prerequisite for the declarative setup in flake.nix --
# see specs/001-declarative-machine-setup/research.md for why this can't be
# folded into bootstrap.zsh: Nix has to exist before anything declarative
# (including this script's own sibling, the flake) can run at all, and
# bootstrap.zsh is the *other*, separate setup path (see README.md's
# "Two setup paths" section) -- keeping this its own script matches how
# git_backup_with_cron.sh already sits next to bootstrap.zsh as its own
# concern, rather than growing bootstrap.zsh to cover both paths.

set -e

if command -v nix > /dev/null 2>&1; then
  echo "Nix already installed, skipping (nix --version: $(nix --version))"
  exit 0
fi

echo "Installing Nix via the Determinate Systems installer"
curl -fsSL https://install.determinate.systems/nix | sh -s -- install

echo "Done. Open a NEW shell (this one won't have Nix on PATH yet), then:"
echo "  nix --version"
echo "to confirm, and see specs/001-declarative-machine-setup/quickstart.md for the next step."
