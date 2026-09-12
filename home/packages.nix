{ pkgs, lib, config, ... }:

{
  # Like-for-like port of bootstrap.zsh's `software_list`, plus the tools
  # installed ad hoc via Homebrew this session (gh, kubectl, go, minikube,
  # protobuf, tree, ffmpeg, gdbm, perl) once the stale-/usr/local-Intel
  # shadowing bug was found and fixed. All of these have real nixpkgs
  # packages, so none of them need Homebrew at all anymore -- see
  # research.md's "What stays on Homebrew" decision (only GUI .app bundles
  # do). `vim` is declared in vim.nix, next to its vim-plug bootstrap, not
  # here.
  home.packages = with pkgs; [
    gcc
    bash
    tig
    icdiff
    python3
    kubectx
    watch
    uv

    gh
    kubectl
    go
    minikube
    protobuf
    tree
    ffmpeg
    gdbm
    perl
  ];

  # specify-cli (GitHub Spec Kit) has no nixpkgs package, so it stays a
  # `uv tool install`, exactly as bootstrap.zsh did it -- just triggered by
  # a home-manager activation script instead of a bash loop. Idempotent the
  # same way the original was: check what's already installed before acting.
  home.activation.installSpecifyCli = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.uv}/bin:$PATH"
    if uv tool list 2>/dev/null | grep -q "^specify-cli "; then
      run uv tool upgrade specify-cli
    else
      run uv tool install specify-cli
    fi
  '';
}
