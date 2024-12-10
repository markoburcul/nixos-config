{ 
  config, 
  pkgs,
  lib,
  ... 
}:
let
  inherit (lib) filterAttrs;
  user = "nebula-mesh";

  servers = {
    "ghosteye" = { isLighthouse = true;  publicIP = "49.13.212.18"; privateIP = "192.170.100.1"; };
    "torvion"  = { isLighthouse = false; publicIP = "88.198.54.19"; privateIP = "192.170.100.2"; };
  };

  isLighthouse = servers.${config.networking.hostName}.isLighthouse;

  lighthouseAddresses = builtins.listToAttrs (
    map (serverName: {
      name = servers.${serverName}.privateIP;
      value = [ "${servers.${serverName}.publicIP}:4242" ];
    }) (builtins.attrNames (filterAttrs (_: v: v.isLighthouse) servers))
  );

  networkingHosts = builtins.listToAttrs (map (serverName: {
    name = servers.${serverName}.privateIP;
    value = [ "${serverName}.mesh" ];
  }) (builtins.attrNames servers));
in 
{
  environment.systemPackages = [ pkgs.nebula ];

  age.secrets = {
    ca-crt-nebula = {
      file = ../secrets/services/nebula/ca.crt.age;
      path = "/etc/nebula/ca.crt";
      mode = "0400";
      owner = user;
      group = user;
    };
    host-crt-nebula = {
      file = ../secrets/services/nebula/${config.networking.hostName}.crt.age;
      path = "/etc/nebula/host.crt";
      mode = "0400";
      owner = user;
      group = user;
    };
    host-key-nebula = {
      file = ../secrets/services/nebula/${config.networking.hostName}.key.age;
      path = "/etc/nebula/host.key";
      mode = "0400";
      owner = user;
      group = user;
    };
  };

  systemd.tmpfiles.rules = [
    "d /etc/nebula/ 700 ${user} ${user}"
  ];

  networking.firewall = {
    trustedInterfaces = [ "nebula.mesh" ];
  };

  networking.hosts = networkingHosts;

  services.nebula.networks.mesh = {
    enable = true;
    isLighthouse = isLighthouse;
    tun.device = "nebula.mesh";
    ca = "/etc/nebula/ca.crt";
    cert = "/etc/nebula/host.crt";
    key = "/etc/nebula/host.key";
    staticHostMap = if isLighthouse then
      {}
    else
      lighthouseAddresses;
    lighthouses = if isLighthouse then
      [ ]
    else
      builtins.attrNames lighthouseAddresses;
    listen.port = 4242;
    firewall = {
      outbound = [
        {
          host = "any";
          port = "any";
          proto = "any";
        }
      ];
      inbound = [
        {
          host = "any";
          port = "any";
          proto = "icmp";
        }
        {
          host = "any";
          port = 22;
          proto = "tcp";
        }
        {
          host = "any";
          port = 3030;
          proto = "tcp";
          group = "geth";
        }
        {
          host = "any";
          port = 9000;
          proto = "tcp";
          group = "monitoring";
        }
        {
          host = "any";
          port = 9080;
          proto = "tcp";
          group = "monitoring";
        }
        {
          host = "any";
          port = 9100;
          proto = "tcp";
          group = "monitoring";
        }
        {
          host = "any";
          port = 16060;
          proto = "tcp";
          group = "monitoring";
        }
        {
          host = "any";
          port = 18550;
          proto = "tcp";
          group = "monitoring";
        }
      ];
    };
  };
}