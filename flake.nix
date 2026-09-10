{
  description = "Declarative machine setup -- replaces bootstrap.zsh + rc_files (see specs/001-declarative-machine-setup)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager }:
    let
      # Single personal machine (see specs/001-declarative-machine-setup) --
      # not parameterized for a fleet. Update these two if you rename the
      # Mac or the primary account.
      username = "song-propel";
      hostname = "mbp23"; # `scutil --get LocalHostName`

      # Apple Silicon only, matching bootstrap.zsh's existing Rosetta guard.
      # Set once, in darwin/configuration.nix's `nixpkgs.hostPlatform`, not
      # duplicated here as a `system` argument -- passing both is the kind
      # of double-definition that only surfaces as a confusing eval error.
    in
    {
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit username; };
        modules = [
          ./darwin/configuration.nix
          ./darwin/homebrew.nix

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit username; };
            home-manager.users.${username} = import ./home/home.nix;
          }
        ];
      };
    };
}
