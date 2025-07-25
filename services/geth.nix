{ config, lib, pkgs, ... }:

with lib;

let
  eachGeth = config.services.geth;

  gethOpts = { config, lib, name, ...}: {

    options = {

      enable = lib.mkEnableOption "Go Ethereum Node";

      port = mkOption {
        type = types.port;
        default = 30303;
        description = "Port number Go Ethereum will be listening on, both TCP and UDP.";
      };

      http = {
        enable = lib.mkEnableOption "Go Ethereum HTTP API";
        address = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Listen address of Go Ethereum HTTP API.";
        };

        port = mkOption {
          type = types.port;
          default = 8545;
          description = "Port number of Go Ethereum HTTP API.";
        };

        apis = mkOption {
          type = types.nullOr (types.listOf types.str);
          default = null;
          description = "APIs to enable over WebSocket";
          example = ["net" "eth"];
        };
      };

      websocket = {
        enable = lib.mkEnableOption "Go Ethereum WebSocket API";
        address = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Listen address of Go Ethereum WebSocket API.";
        };

        port = mkOption {
          type = types.port;
          default = 8546;
          description = "Port number of Go Ethereum WebSocket API.";
        };

        apis = mkOption {
          type = types.nullOr (types.listOf types.str);
          default = null;
          description = "APIs to enable over WebSocket";
          example = ["net" "eth"];
        };
      };

      authrpc = {
        enable = lib.mkEnableOption "Go Ethereum Auth RPC API";
        address = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Listen address of Go Ethereum Auth RPC API.";
        };

        port = mkOption {
          type = types.port;
          default = 8551;
          description = "Port number of Go Ethereum Auth RPC API.";
        };

        vhosts = mkOption {
          type = types.nullOr (types.listOf types.str);
          default = ["localhost"];
          description = "List of virtual hostnames from which to accept requests.";
          example = ["localhost" "geth.example.org"];
        };

        jwtsecret = mkOption {
          type = types.str;
          default = "";
          description = "Path to a JWT secret for authenticated RPC endpoint.";
          example = "/var/run/geth/jwtsecret";
        };
      };

      metrics = {
        enable = lib.mkEnableOption "Go Ethereum prometheus metrics";
        address = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Listen address of Go Ethereum metrics service.";
        };

        port = mkOption {
          type = types.port;
          default = 6060;
          description = "Port number of Go Ethereum metrics service.";
        };
      };

      bootnodes = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
        description = "List of enode URLs for P2P discovery bootstrap";
        example = [ "enode://ac906289e4b7f12df423d654c5a962b6ebe5b3a74cc9e06292a85221f9a64a6f1cfdd6b714ed6dacef51578f92b34c60ee91e9ede9c7f8fadc4d347326d95e2b@146.190.13.128:30303" "enode://a3435a0155a3e837c02f5e7f5662a2f1fbc25b48e4dc232016e1c51b544cb5b4510ef633ea3278c0e970fa8ad8141e2d4d0f9f95456c537ff05fdf9b31c15072@178.128.136.233:30303" ];
      };

      datadir = mkOption {
        type = types.str;
        default = "";
        description = "Path to the node data directory.";
        example = "/var/run/geth/jwtsecret";
      };

      network = mkOption {
        type = types.nullOr (types.enum [ "goerli" "holesky" ]);
        default = null;
        description = "The network to connect to. Mainnet (null) is the default ethereum network.";
      };

      syncmode = mkOption {
        type = types.enum [ "snap" "fast" "full" "light" ];
        default = "snap";
        description = "Blockchain sync mode.";
      };

      gcmode = mkOption {
        type = types.enum [ "full" "archive" ];
        default = "full";
        description = "Blockchain garbage collection mode.";
      };

      maxpeers = mkOption {
        type = types.int;
        default = 50;
        description = "Maximum peers to connect to.";
      };

      extraArgs = mkOption {
        type = types.listOf types.str;
        description = "Additional arguments passed to Go Ethereum.";
        default = [];
      };

      package = mkPackageOption pkgs [ "go-ethereum" "geth" ] { };
    };
  };
in

{

  ###### interface

  options = {
    services.geth = mkOption {
      type = types.attrsOf (types.submodule gethOpts);
      default = {};
      description = "Specification of one or more geth instances.";
    };
  };

  ###### implementation

  config = mkIf (eachGeth != {}) {

    environment.systemPackages = flatten (mapAttrsToList (gethName: cfg: [
      cfg.package
    ]) eachGeth);

    systemd.services = mapAttrs' (gethName: cfg: let
      statedir = "goethereum/${gethName}/${if (cfg.network == null) then "mainnet" else cfg.network}";
    in (
      nameValuePair "geth-${gethName}" (mkIf cfg.enable {
      description = "Go Ethereum node (${gethName})";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        StateDirectory = "${cfg.datadir}/${statedir}";

        # Hardening measures
        PrivateTmp = "true";
        ProtectSystem = "full";
        NoNewPrivileges = "true";
        PrivateDevices = "true";
        MemoryDenyWriteExecute = "true";
      };

      script = ''
        ${cfg.package}/bin/geth \
          --nousb \
          --ipcdisable \
          ${optionalString (cfg.network != null) ''--${cfg.network}''} \
          --syncmode ${cfg.syncmode} \
          --gcmode ${cfg.gcmode} \
          --port ${toString cfg.port} \
          --maxpeers ${toString cfg.maxpeers} \
          ${optionalString cfg.http.enable ''--http --http.addr ${cfg.http.address} --http.port ${toString cfg.http.port}''} \
          ${optionalString (cfg.http.apis != null) ''--http.api ${lib.concatStringsSep "," cfg.http.apis}''} \
          ${optionalString cfg.websocket.enable ''--ws --ws.addr ${cfg.websocket.address} --ws.port ${toString cfg.websocket.port}''} \
          ${optionalString (cfg.websocket.apis != null) ''--ws.api ${lib.concatStringsSep "," cfg.websocket.apis}''} \
          ${optionalString cfg.metrics.enable ''--metrics --metrics.addr ${cfg.metrics.address} --metrics.port ${toString cfg.metrics.port}''} \
          --authrpc.addr ${cfg.authrpc.address} --authrpc.port ${toString cfg.authrpc.port} --authrpc.vhosts ${lib.concatStringsSep "," cfg.authrpc.vhosts} \
          ${if (cfg.authrpc.jwtsecret != "") then ''--authrpc.jwtsecret ${cfg.authrpc.jwtsecret}'' else ''--authrpc.jwtsecret ${cfg.datadir}/geth/jwtsecret''} \
          ${optionalString (cfg.bootnodes != null) ''--bootnodes ${lib.concatStringsSep "," cfg.bootnodes}''} \
          ${lib.escapeShellArgs cfg.extraArgs} \
          --datadir ${cfg.datadir}
      '';
    }))) eachGeth;

  };

}
