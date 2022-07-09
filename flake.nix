{
  description = "Home Manager configuration of Jane Doe";

  inputs = {
	  # Package sets
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-22.05-darwin";
    nixpkgs-unstable.url = github:NixOS/nixpkgs/nixpkgs-unstable;
    # Environment/system management
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    # darwin
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, darwin, home-manager, ... }@inputs:
  let
    system = "x86_64-darwin";
    inherit (darwin.lib) darwinSystem;
    inherit (inputs.nixpkgs-unstable.lib) attrValues makeOverridable optionalAttrs singleton;
    pkgs = nixpkgs.legacyPackages.${system};

  # Configuration for `nixpkgs`
  nixpkgsConfig = {
    config = { allowUnfree = true; };
    overlays = attrValues self.overlays ++ singleton (
      # Sub in x86 version of packages that don't build on Apple Silicon yet
      final: prev: (optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
        inherit (final.pkgs-x86)
          discord
          yadm;
      })
    );
  };
  in {
    # homeConfigurations.nipeharefa = home-manager.lib.homeManagerConfiguration {
      # inherit pkgs;

      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      # modules = [
      #   ./home.nix
      # ];

      # Optionally use extraSpecialArgs
      # to pass through arguments to home.nix
    # };
    darwinConfigurations = rec {
      nipeharefa = darwinSystem {
        system = "x86_64-darwin";
        modules = [
          ./configuration.nix
          home-manager.darwinModules.home-manager
          (
            { pkgs, ... }:
            {

                # Configure default shell for zainfathoni to fish
                # users.users.zainfathoni.shell = pkgs.fish;
                # Somehow this 👆 doesn't work.
                # So I did this instead: https://stackoverflow.com/a/26321141/3187014
                # 
                # ```shell
                # $ sudo sh -c "echo $(which fish) >> /etc/shells"
                # $ chsh -s $(which fish)
                # ```

                # `home-manager` config
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.nipeharefa = import ./home.nix;
              }
          )
        ];
      };
    };
  };
}