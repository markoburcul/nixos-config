{
  pkgs ? import <nixpkgs> { }
}: pkgs.mkShell {
    packages = with pkgs; [
      jq
      just
      nixos-rebuild
      util-linux
    ];
  }
