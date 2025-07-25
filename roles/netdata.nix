{ config, ... }:

let
  inherit (config) services;
  listenPort = 9000;
in {
  # Daemon
  services.netdata.enable = true;
  services.netdata.config = {
    "global" = {
      "hostname" = config.networking.hostName;
      "run as user" = "root";
      "update every" = 5;
      "memory mode" = "ram";
      "error log" = "/var/log/netdata/error.log";
      "debug log" = "none";
      "access log" = "none";
    };
    "web" = {
      "default port" = listenPort;
      "allow connections from" = "localhost *";
    };
    "health" = { "enabled" = "no"; };
    "statsd" = { "enabled" = "no"; };
    "plugins" = {
      "idlejitter" = "no";
      "python.d" = "yes";
      "node.d" = "no";
      "charts.d" = "no";
      "fping" = "no";
      "tc" = "no";
    };
    "plugin:apps" = { "update every" = 10; };
    "plugin:proc:diskspace" = {
      "update every" = 10;
      "check for new mount points every" = 0;
    };
    "plugin:proc" = {
      "/proc/net/snmp" = "no";
      "/proc/net/snmp6" = "no";
      "/proc/net/ip_vs/stats" = "no";
      "/proc/net/stat/synproxy" = "no";
      "/proc/net/stat/nf_conntrack" = "no";
    };
  };
}
