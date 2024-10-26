{ pkgs, config, lib, secret, ... }:

let
  inherit (config) services;
  inherit (lib) types mkEnableOption mkOption mkIf listToAttrs;

  htpasswd = secret "service/landing/htpasswd";

  cfg = config.services.landing;

  landingPage = pkgs.callPackage ../templates/landing.index.nix {
    inherit config;
    inherit (cfg) proxyServices;
  };
in {
  options = {
    services = {
      landing = {
        enable = mkEnableOption "Enable a fast and simple webserver for your files.";

        serverTLSCertificate = mkOption {
          type = types.path;
          default = "";
          description = ''
            Location of file with server TLS certificate.
          '';
        };

        serverTLSKey = mkOption {
          type = types.path;
          default = "";
          description = ''
            Location of file with server TLS key.
          '';
        };

        CACertificate = mkOption {
          type = types.path;
          default = "";
          description = ''
            Location of file with CA certificate.
          '';
        };

        CRL= mkOption {
          type = types.path;
          default = "";
          description = ''
            Location of file with CRL in PEM format.
          '';
        };

        # This list of sets represents service proxies we support.
        # To simplify merging with 'locations' we use the
        # Nginx path as 'name' and rest of config as 'value'.
        proxyServices = mkOption {
          type = types.listOf types.attrs;
          default = [ ];
          description =
            "List of objects defining paths and Nginx proxy configs.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      enableReload = true;
      config = ''
      events {
          use epoll;
          worker_connections 4096;
      }
      http {
        server {
            listen 80;
            server_name ${config.networking.fqdn};

            location / {
                return 301 https://$host$request_uri;
            }
        }

        server {
            listen 443 ssl;
            server_name ${config.networking.fqdn};

            ssl_certificate     ${cfg.serverTLSCertificate};
            ssl_certificate_key ${cfg.serverTLSKey};
            
            # Path to Certificate Authority (CA) file
            ssl_client_certificate ${cfg.CACertificate};
            
            # Path to Certificate Revocation List (CRL) file
            ssl_crl ${cfg.CRL};

            ssl_verify_client on;

            access_log /var/log/nginx/mtls.access.log;
            error_log /var/log/nginx/mtls.error.log;

            location /grafana/ {
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_pass http://localhost:3000/;
            }
            location /prometheus/ {
              proxy_pass http://localhost:9090/;
            }
        }
      }
      '';
    };

    /* Firewall */
    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
