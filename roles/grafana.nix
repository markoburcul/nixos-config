{ 
  lib,
  config,
  ... 
}:
let
  inherit (config) services;
in {
  options.grafana = {
    adminPasswordFile = lib.mkOption {
      default = "service/grafana/pass";
    };
  };
  config = let
    cfg = config.grafana;
    enabledDatasources = lib.filterAttrs (name: value: value.enable) {
      prometheus = {
        enable = config.services.prometheus.enable or false;
        datasource = {
          name = "Prometheus";
          type = "prometheus";
          url = "http://localhost:${toString config.services.prometheus.port}/";
          isDefault = true;
          jsonData = { timeInterval = "10s"; };
        };
      };
      loki = {
        enable = config.services.loki.enable or false;
        datasource = {
          name = "Loki";
          type = "loki";
          url = "http://localhost:3030/";
          jsonData = { timeInterval = "10s"; };
        };
      };
    };
  in {
    age.secrets = {
      grafana-secret = {
        file = ../secrets/services/grafana/pass.age;
        path = "/persist/monitoring/grafana/pass";
        owner = "grafana";
      };
    };
    
    services.grafana = {
      enable = true;

      settings = {
        server = {
          protocol = "http";
          http_addr = "127.0.0.1";
          http_port = 3000;
          domain = config.networking.fqdn;
          root_url = "%(protocol)s://%(domain)s:%(http_port)s/";
        };
        security = {
          admin_user = "markob";
          admin_password = "$__file{/persist/monitoring/grafana/pass}";
          serve_from_sub_path = true;
          allow_embedding = true;
        };
      };

      dataDir = "/persist/monitoring/grafana";

      provision = {
        enable = true;
        datasources.settings = {
          datasources = lib.attrValues (lib.mapAttrs (_: v: v.datasource) enabledDatasources);
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /persist/monitoring/grafana 770 grafana grafana"
    ];
  };
}