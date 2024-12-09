{ config, lib, pkgs, ... }:

let
  inherit (lib)
    types mkEnableOption mkOption mkIf length
    escapeShellArgs literalExpression toUpper
    boolToString concatMapStringsSep optionalString optionalAttrs;

  cfg = config.services.mev-boost;
in {
  options = {
    services = {
      mev-boost = {
        enable = mkEnableOption "MEV-Boost service.";

        package = mkOption {
          type = types.package;
          default = pkgs.mev-boost;
          defaultText = literalExpression "pkgs.mev-boost";
          description = lib.mdDoc "Package to use mev boost.";
        };

        service = {
          user = mkOption {
            type = types.str;
            default = "mev-boost";
            description = "Username for MEV-Boost service.";
          };

          group = mkOption {
            type = types.str;
            default = "mev-boost";
            description = "Group name for MEV-Boost service.";
          };
        };

        listenAddr = mkOption {
          type = types.str;
          default = "localhost:18550";
          description = "Listen address for mev-boost server.";
        };

        holesky = mkOption {
          type = types.bool;
          default = false;
          description = "Use Holesky network.";
        };

        loglevel = mkOption {
          type = types.str;
          default = "info";
          description = "Minimum log level: trace, debug, info, warn/warning, error, fatal, panic.";
        };

        mainnet = mkOption {
          type = types.bool;
          default = false;
          description = "Use Mainnet network.";
        };

        minBid = mkOption {
          type = types.float;
          default = 0.05;
          description = "Minimum bid to accept from a relay.";
        };

        relays = mkOption {
          type = types.str;
          default = "";
          description = "Comma-separated list of relay URLs.";
        };

        relayCheck = mkOption {
          type = types.bool;
          default = false;
          description = "Check relay status on startup and status API call.";
        };

        requestTimeoutGetHeader = mkOption {
          type = types.int;
          default = 950;
          description = "Timeout for getHeader requests to the relay (ms).";
        };

        requestTimeoutGetPayload = mkOption {
          type = types.int;
          default = 4000;
          description = "Timeout for getPayload requests to the relay (ms).";
        };

        requestTimeoutRegval = mkOption {
          type = types.int;
          default = 3000;
          description = "Timeout for registerValidator requests (ms).";
        };

        sepolia = mkOption {
          type = types.bool;
          default = false;
          description = "Use Sepolia network.";
        };

        version = mkOption {
          type = types.bool;
          default = false;
          description = "Print the version of mev-boost.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    users.users = optionalAttrs (cfg.service.user == "mev-boost") {
      mev-boost = {
        group = cfg.service.group;
        description = "MEV-Boost service user";
        isSystemUser = true;
      };
    };

    users.groups = optionalAttrs (cfg.service.user == "mev-boost") {
      mev-boost = { };
    };

    systemd.services.mev-boost = {
      enable = true;
      serviceConfig = {
        User = cfg.service.user;
        Group = cfg.service.group;

        ExecStart = ''
          ${cfg.package}/bin/mev-boost \
            -addr ${cfg.listenAddr} \
            ${optionalString cfg.mainnet "-mainnet"} \
            ${optionalString cfg.holesky "-holesky"} \
            ${optionalString cfg.sepolia "-sepolia"} \
            -loglevel ${cfg.loglevel} \
            -min-bid ${toString cfg.minBid} \
            -relays "${cfg.relays}" \
            ${optionalString cfg.relayCheck "-relay-check"} \
            -request-timeout-getheader ${toString cfg.requestTimeoutGetHeader} \
            -request-timeout-getpayload ${toString cfg.requestTimeoutGetPayload} \
            -request-timeout-regval ${toString cfg.requestTimeoutRegval} \
            ${optionalString cfg.version "-version"}
        '';
        Restart = "on-failure";
      };
      wantedBy = [ "multi-user.target" ];
      requires = [ "network.target" ];
    };
  };
}
