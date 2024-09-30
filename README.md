# Usage

This repo is still WIP!

When bootstrapping a new host:
```bash
nix run github:nix-community/nixos-anywhere -- --flake .#generic root@12.34.56.78
```

All of the configuration for the host should be edited in the repository and when you want to update the host just run:
```bash
nixos-rebuild switch --flake .#generic --target-host "root@12.34.56.78"
```