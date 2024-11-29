{ ... }:

{
  imports = [
    ./netdata.nix
    ./prometheus.nix
    ./grafana.nix
    ./promtail.nix
    ./loki.nix
  ];
}
