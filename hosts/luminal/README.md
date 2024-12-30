# Description

Configuration for Hetzner Auction host.

Public IP: 94.130.49.102
Nebula Private IP: 192.170.100.4
Nebula Groups: near, ssh
DNS: luminal.cybercraftsolutions.eu

# Hardware

* Gigabyte B360HD3PLM-CF
* Intel Core i7-8700
* SSD 2x SSD SAMSUNG MZVLB1T0HALR-00000 M.2 NVMe 1 TB
* RAM 4x RAM 16 GB DDR4 2666MHz

# Installation

- since this is a bare metal server, you need to enter rescue mode in Hetzner Robot
- after that run nixos-anywhere command:
```bash
nix run github:nix-community/nixos-anywhere -- --flake .#luminal root@94.130.49.102
```
