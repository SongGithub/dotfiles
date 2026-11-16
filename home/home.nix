{ pkgs, username, ... }:

{
  imports = [
    ./shell.nix
    ./packages.nix
    ./vim.nix
    ./sublime-text.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # Required by home-manager; bump only deliberately, never as a side
  # effect of an unrelated change (same rule as system.stateVersion).
  home.stateVersion = "24.05";

  # home-manager manages itself once bootstrapped from the nix-darwin module.
  programs.home-manager.enable = true;

  # `mkdir -p ~/workspace` from bootstrap.zsh.
  home.file."workspace/.keep".text = "";
}
