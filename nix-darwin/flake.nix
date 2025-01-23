{
  description = "Development packages for Mike Flood";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    zig.url = "github:mitchellh/zig-overlay";
    ghostty.url = "github:ghostty-org/ghostty";

    # rust overlay
    fenix = {
      url = "github:nix-community/fenix/monthly";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-flake = {
      url = "github:FloodCreux/neovim-ide";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: Remove once nixpkgs yazi version > 0.4.0
    yazi = {
      url = "github:sxyazi/yazi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      darwin,
      ...
    }:
    let
      pkgs-config = {
        allowUnfree = true;
        allowUnsupportedSystem = true;
        permittedInsecurePackages = [
          "dotnet-core-combined"
          "dotnet-sdk-6.0.428"
          "dotnet-sdk-wrapped-6.0.428"
          "dotnet-runtime-6.0.36"
          "dotnet-runtime-wrapped-6.0.36"
        ];
      };

    in
    {
      darwinConfigurations = {
        default =
          let
            system = "aarch64-darwin";
            username = "mike";

            overlays = import ./lib/overlays.nix { inherit inputs system username; };

            pkgs = import nixpkgs {
              inherit overlays system;

              config = pkgs-config;
            };
          in
          pkgs.mkDarwin {
            inherit
              darwin
              system
              pkgs
              username
              ;
          };

        work =
          let
            system = "aarch64-darwin";
            username = "chmc-h022fl97xj";

            overlays = import ./lib/overlays.nix { inherit inputs system username; };

            pkgs = import nixpkgs {
              inherit system overlays;

              config = pkgs-config;
            };
          in
          pkgs.mkDarwin {
            inherit
              darwin
              system
              pkgs
              username
              ;
          };
      };
    };
}
