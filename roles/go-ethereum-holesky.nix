{ config, lib, pkgs, secret, ... }:

# Temporary validator workshop nodes.
{
  disabledModules = [
     "services/blockchain/ethereum/geth.nix"
  ];
  imports = [
    ../services/geth.nix
  ];

  options.nimbus = {
    devp2pPort = lib.mkOption { default = 9800; };
    jwtsecret  = lib.mkOption { default = "services/geth/jwt-secret"; };
  };

  config = let
    cfg = config.nimbus;
  in {
    # Secrets
    age.secrets = {
      jwt-secret = {
        file = ../secrets/services/geth/jwt-secret.age;
        path = "/persist/workshop/geth/jwt-secret";
        owner = "geth-holesky";
        group = "geth-holesky";
        mode = "440";
      };
    };

    services.geth = {
      "holesky" = {
        enable = true;
        network = "holesky";
        syncmode = "full";
        maxpeers = 50;
        port = cfg.devp2pPort;
        package = pkgs.callPackage ../pkgs/go-ethereum.nix { };
        datadir = "/persist/workshop/geth/data";
        metrics = {
          enable = true;
          port = 16060;
          address = "0.0.0.0";
        };
        http = {
          enable = true;
          port = 18545;
          address = "0.0.0.0";
          apis = ["net" "eth" "admin"];
        };
        websocket = {
          enable = true;
          port = 18546;
          address = "0.0.0.0";
          apis = ["net" "eth" "admin"];
        };
        authrpc = {
          enable = true;
          port = 18551;
          address = "127.0.0.1";
          vhosts = ["localhost" "127.0.0.1"];
          jwtsecret = "/persist/workshop/geth/jwt-secret";
        };
        bootnodes = [ "enode://ac906289e4b7f12df423d654c5a962b6ebe5b3a74cc9e06292a85221f9a64a6f1cfdd6b714ed6dacef51578f92b34c60ee91e9ede9c7f8fadc4d347326d95e2b@146.190.13.128:30303" "enode://a3435a0155a3e837c02f5e7f5662a2f1fbc25b48e4dc232016e1c51b544cb5b4510ef633ea3278c0e970fa8ad8141e2d4d0f9f95456c537ff05fdf9b31c15072@178.128.136.233:30303" ];
        extraArgs = [
          "--verbosity=3"
          "--log.json=true"
          "--nat=any"
          "--v5disc"
        ];
      };
    };

    # Users
    users.users.geth-holesky = {
      group = "geth-holesky";
      home = "/persist/workshop/geth";
      uid = 6000;
      description = "Go ethereum service user";
      isSystemUser = true;
    };

    users.groups.geth-holesky = {
      gid = 6000;
    };

    systemd.tmpfiles.rules = [
      "d /persist/workshop/geth/data 760 geth-holesky geth-holesky"
    ];

    # Pass JWT secret using LoadCredential.
    systemd.services.geth-holesky = {
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "geth-holesky";
        Group = "geth-holesky";
      };
    };

    /* Firewall */
    networking.firewall.allowedTCPPorts = [ cfg.devp2pPort ];
    networking.firewall.allowedUDPPorts = [ cfg.devp2pPort ];
  };
}
