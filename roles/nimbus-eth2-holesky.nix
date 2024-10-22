{ pkgs, lib, config, ... }:

let
  services = config.services;
in {
  imports = [
    ../services/nimbus-eth2.nix
  ];

  options.nimbus = {
    network      = lib.mkOption { default = "holesky"; };
    listenPort   = lib.mkOption { default = 9802; }; # WebDAV Source TLS/SSL
    discoverPort = lib.mkOption { default = 9802; }; # WebDAV Source TLS/SSL
    #feeRecipient = lib.mkOption { default = "service/nimbus/fee-recipient"; };
    jwtSecret    = lib.mkOption { default = "services/geth/jwt-secret"; };
  };

  config = let
    cfg = config.nimbus;
  in {
    # Secrets
    age.secrets = {
      jwt-secret-nimbus = {
        file = ../secrets/services/nimbus/jwt-secret.age;
        path = "/persist/workshop/nimbus/jwt-secret";
        owner = "nimbus";
        group = "nimbus";
        mode = "440";
      };
      #fee-recipient = {
      #  file = ../secrets/services/nimbus/fee-recipient.age;
      #  path = "/persist/workshop/nimbus/fee-recipient";
      #  owner = "nimbus";
      #  group = "nimbus";
      #  mode = "440";
      #};
    };

    services.nimbus-eth2 = {
      enable = true;
      inherit (cfg) network listenPort discoverPort;
      log = { 
        level = "info"; 
        format = "json"; 
      };
      metrics = { 
        enable = true; 
        address = "0.0.0.0"; 
      };
      rest = { 
        enable = true; 
        address = "0.0.0.0"; 
      };
      dataDir = "/persist/workshop/nimbus";
      threadsNumber = 0; /* 0 == auto */
      /* Higher resource usage for small increase in rewards. */
      subAllSubnets = false;
      /* Costs two slot rewards at restart if enabled. */
      doppelganger = false;
      /* If Go-Ethereum is running use it. */
      execURLs =
        if services.erigon.enable then
        ["http://localhost:${builtins.toString services.erigon.settings.${"authrpc.port"}}/"]
        else if services.geth.${cfg.network}.enable then
        ["http://localhost:${builtins.toString services.geth.${cfg.network}.authrpc.port}/"]
        else
        [];
      jwtSecret = "/persist/workshop/nimbus/jwt-secret";
      # TODO: enable loading variables from files using systemd
      #suggestedFeeRecipient = "";
    };

    systemd.tmpfiles.rules = [
      "d /persist/workshop/nimbus 700 nimbus nimbus"
      "d /persist/workshop/nimbus/era 700 nimbus nimbus"
    ];

    users.users.nimbus.uid = 5000;
    users.groups.nimbus.gid = 5000;

    systemd.services.nimbus-eth2 = {
      serviceConfig = {
        Nice = -20;
        IOSchedulingClass = "realtime";
        IOSchedulingPriority = 0;
        DynamicUser = lib.mkForce false;
        User = "nimbus";
        Group = "nimbus";
      };
    };

    # Firewall
    networking.firewall.allowedTCPPorts = [ cfg.listenPort ];
    networking.firewall.allowedUDPPorts = [ cfg.discoverPort ];
  };
}
