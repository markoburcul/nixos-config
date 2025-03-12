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
        bootnodes = [ "enode://0a9a93c1b7879af75e4794327e6d7a54359fc6ab3c7876b41694fcab2c08552da0ead23b5668621c94402fdd4725e844c21896810584baeb34831c48fe78628b@162.19.103.136:20010" ];
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
