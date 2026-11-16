{ ... }:

{
  # Narrow, deliberate use of Homebrew -- only for what Nix cannot package on
  # macOS itself (see data-model.md's "GUI-only Application" entity and
  # research.md's "What stays on Homebrew" decision). Every CLI tool that
  # used to be in bootstrap.zsh's `software_list` (gcc, tig, icdiff, vim,
  # gh, kubectl, go, minikube, protobuf, tree, ffmpeg, gdbm, perl, uv, ...)
  # is a real nixpkgs package now -- see home/packages.nix.
  homebrew = {
    enable = true;

    # Nix has no equivalent to a `.app` GUI bundle, so `claude-code`'s cask
    # form stays here even though the CLI binary itself is just a binary --
    # this is the same cask bootstrap.zsh installed via
    # `brew install --cask claude-code`.
    casks = [ "claude-code" ];

    # Sublime Text itself is deliberately NOT declared here: bootstrap.zsh
    # never installed it either (README's Assumptions section has always
    # required it pre-installed manually) -- it only links the `subl` CLI
    # shim if the .app is already present. See home/sublime-text.nix for
    # that shim + the update-check-nag fix, ported like-for-like.
    taps = [ ];
    brews = [ ];

    onActivation = {
      # Mirrors bootstrap.zsh explicitly calling `brew upgrade --cask
      # claude-code` on every run. Intentionally not "zap" or "uninstall" --
      # this migration must not remove anything a human installed by hand.
      upgrade = true;
      cleanup = "none";
    };
  };
}
