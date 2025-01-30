# Geth

1. In `./pkgs/go-ethereum.nix` change the version to newest.
2. Go into terminal and enter to find out SHA256 of the newest version:
```bash
nix-shell -p nix-prefetch-git
nix-prefetch-git --url https://github.com/ethereum/go-ethereum --rev <VERSION>
```
3. Comment out vendorHash and run:
```bash
nixos-rebuild switch --flake .#torvion --target-host "root@torvion"
```
4. You should see in the output new sha256 from vendor if it has changed, update it  
, uncomment it and run nixos-rebuild again
5. Monitor in the Grafana service logs if everything is okay