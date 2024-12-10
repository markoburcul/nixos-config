{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgsNew.url = "nixpkgs/nixos-24.11";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgsNew,
      disko,
      agenix,
      ...
    }:
    let
      overlay = final: prev: {
        dashy-ui = (import nixpkgsNew { system = final.system; }).dashy-ui;
      };
      overlayModule = ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay ]; });
    in 
    {
      nixosConfigurations = {
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
          specialArgs.channels = { inherit nixpkgs nixpkgsNew agenix; };
          modules = [
            overlayModule
            agenix.nixosModules.default
            ./hosts/ghosteye/configuration.nix
            ./hosts/ghosteye/hardware-configuration.nix
          ];
        };
      };
    };
}
