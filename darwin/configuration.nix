{ pkgs, username, ... }:

{
  # --- One-time manual prerequisites (not managed by this flake) ---
  # 1. Xcode Command Line Tools: `xcode-select --install`. bootstrap.zsh ran
  #    this on every invocation with `|| true`; Nix/nix-darwin has no module
  #    for it (it's an Apple-distributed component, not a Nix package) and
  #    also needs it present to build things, so it must already exist
  #    before `darwin-rebuild` can even run.
  # 2. Nix itself: see specs/001-declarative-machine-setup/research.md and
  #    quickstart.md for the Determinate Systems installer command. This is
  #    the one unavoidable imperative step (chicken-and-egg: Nix has to
  #    exist before anything declarative can run).

  # Determinate's installer manages the Nix daemon/config itself; letting
  # nix-darwin *also* manage it (the default) fights the same settings from
  # two owners. Matches the installer choice in research.md.
  nix.enable = false;

  system.primaryUser = username;

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  # `bootstrap.zsh` never wrote persistent `defaults write ...` settings
  # (the aliases file's show/hide-desktop etc. are on-demand, not applied at
  # boot), so there is nothing to port into `system.defaults` here -- this
  # is intentionally empty, not an oversight.

  # Required by nix-darwin; bump only deliberately (see nix-darwin release
  # notes), never as a side effect of an unrelated change.
  system.stateVersion = 5;

  nixpkgs.hostPlatform = "aarch64-darwin";
}
