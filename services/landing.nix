{ pkgs, config, lib, secret, ... }:

let
  inherit (config) services;
  inherit (lib) types mkEnableOption mkOption mkIf listToAttrs;

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
      eventsConfig = ''
        use epoll;
        worker_connections 4096;
      '';
      virtualHosts."${config.networking.fqdn}" = {
        forceSSL = true;
        sslCertificateKey = "${cfg.serverTLSKey}";
        sslCertificate = "${cfg.serverTLSCertificate}";
        extraConfig = ''
          # Path to Certificate Authority (CA) file
          ssl_client_certificate ${cfg.CACertificate};
          
          # Path to Certificate Revocation List (CRL) file
          ssl_crl ${cfg.CRL};
           
          ssl_verify_client on;

          access_log /var/log/nginx/mtls.access.log;
          error_log /var/log/nginx/mtls.error.log;
        '';
        locations."/grafana/" = {
          proxyPass = "http://localhost:3000/";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
        
        locations."/prometheus/" = {
          proxyPass = "http://localhost:9090/";
        };
      };
    };

    /* Firewall */
    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
