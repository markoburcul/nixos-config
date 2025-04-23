{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/bf6fc3eac7ad1cd7992ba1985882f68932a27b52";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      agenix,
      ...
    }:
    let
      allowUnfreeModule = ({ config, pkgs, ... }: {
        nixpkgs.config.allowUnfree = true;
      });
      stableSystems = [
        "x86_64-linux" "aarch64-linux"
        "x86_64-darwin" "aarch64-darwin"
        "x86_64-windows"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs stableSystems (system: f system);
      pkgsFor = forAllSystems ( system: import nixpkgs { inherit system; } );
    in 
    {
      devShells = forAllSystems (system: {
        default = pkgsFor.${system}.callPackage ./shells/default.nix { };
      });

      nixosConfigurations = {
        doma = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs.channels = { inherit nixpkgs agenix; };
          modules = [
            allowUnfreeModule
            disko.nixosModules.disko
            agenix.nixosModules.default
            ./hosts/doma/configuration.nix
            ./hosts/doma/hardware-configuration.nix
          ];
        };
        torvion = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs.channels = { inherit nixpkgs disko agenix; };
          modules = [
            disko.nixosModules.disko
            agenix.nixosModules.default
            ./hosts/torvion/configuration.nix
            ./hosts/torvion/hardware-configuration.nix
            ./hosts/torvion/disk-config.nix
          ];
        };
        ghosteye = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs.channels = { inherit nixpkgs agenix; };
          modules = [
            agenix.nixosModules.default
            ./hosts/ghosteye/configuration.nix
            ./hosts/ghosteye/hardware-configuration.nix
          ];
        };
        luminal = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs.channels = { inherit nixpkgs disko agenix; };
          modules = [
            disko.nixosModules.disko
            agenix.nixosModules.default
            ./hosts/luminal/configuration.nix
            ./hosts/luminal/hardware-configuration.nix
            ./hosts/torvion/disk-config.nix
          ];
        };
      };
    };
}
