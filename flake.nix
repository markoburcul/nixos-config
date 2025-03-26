{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
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
    in 
    {
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
