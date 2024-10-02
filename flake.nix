{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
      };
    };
}
