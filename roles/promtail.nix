{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.services.promtail;
in
{
  options = {
    services.promtail = {
      lokiHost = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "The hostname of the Loki server";
      };
      lokiPort = mkOption {
        type = types.int;
        default = 3030;
        description = "The port of the Loki server";
      };
    };
  };
  config = mkIf cfg.enable {
    services.promtail = {
      configuration = {
        server = {
          http_listen_port = 9080;
          grpc_listen_port = 0;
        };
        positions = {
          filename = "/tmp/positions.yaml";
        };
        clients = [{
          url = "http://${cfg.lokiHost}:${toString cfg.lokiPort}/loki/api/v1/push";
        }];
        scrape_configs = [{
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = "${config.networking.hostName}.mesh";
            };
          };
          relabel_configs = [{
            source_labels = [ "__journal__systemd_unit" ];
            target_label = "unit";
          }];
        }];
      };
    };
  };
}