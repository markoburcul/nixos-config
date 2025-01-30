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

## VPN

The VPN is created using [Nebula](https://nebula.defined.net/docs/). 
To add a new host to existing network it is necessary to first create the certificte and key for it using `nebula-cert`.
The command should be executed in the directory that is not tracked by git `./certificates/nebula` and the password for CA file is in BitWarden.
```bash
 nebula-cert sign -name "newhost" -ip "192.170.100.10/24" -groups "mygroup,ssh" 
```
The groups are useful when defining the firewall rules in the nebula role.


### Hetzner auction
https://radar.iodev.org/analyze?filter=N4IgbgpgTgzglgewHYgFwEYA0IoQMYRIAuANgJ4DKEhaRUArhNiQngIZGJIDi0AtmyRlaDJiBbtOyAGJwkJQQBMRjbHgAO9AMIJ6xNFhAb6ASWIQSKscYCCAWQAiV7FDZ8zRaEjYkKcAF4QaADaACyYAGwAutgwMIoAcmB8EDp6RCEADJgAzDEgcYnJEB5ePn6BIeHoAEz5hRQcbGn6qMHZ6PXxjURspVDevgFBbVih+QAWiootGW3ZmZPT-YMVI2GY6NGxFvieig5NBOawIfW7ePtamnYIihYwZ9gQAB50bDAAolpaaEj0JBIzzerhgJgSJl+qH+gOB7xgAAkAOoAJTQADMfDAxK94dwAAoAVQxWJxII+KPxFBJJGxAF8gA