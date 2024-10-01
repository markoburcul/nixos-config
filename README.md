# Usage

## Bootstrapping a new host

When bootstrapping a new host:
    - create a new directory under `./hosts/<new-host-name>`
    - create `configuration.nix`, `hardware-configuration.nix` and `disk-config.nix` files where you
    specify the exact configuration of the new host
    - add the target in the `flake.nix` file for the new host
    - run command:
```bash
nix run github:nix-community/nixos-anywhere -- --flake .#name-of-the-host root@12.34.56.78
```

## Updating the host

All of the configuration for the host should be edited in the repository and when you want to update the host just run:
```bash
nixos-rebuild switch --flake .#name-of-the-host --target-host "root@12.34.56.78"
```