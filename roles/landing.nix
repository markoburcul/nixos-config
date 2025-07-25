{ pkgs, config, channels, lib, ... }:
let
  fqdn = config.networking.fqdn;
  domain = "cybercraftsolutions.eu";
in
{
  imports = [
    "${channels.nixpkgsNew}/nixos/modules/services/web-apps/dashy.nix"
  ];

  systemd.tmpfiles.rules = [
    "d /etc/nginx/ssl/ 760 nginx nginx"
    "d /etc/nginx/pki/ 760 nginx nginx"
  ];

  age.secrets = {
    server-crt = {
      file = ../secrets/services/landing/server.crt.age;
      path = "/etc/nginx/ssl/server.crt";
      owner = "nginx";
    };
    server-key = {
      file = ../secrets/services/landing/server.key.age;
      path = "/etc/nginx/ssl/server.key";
      owner = "nginx";
    };
    ca-crt = {
      file = ../secrets/services/landing/ca.crt.age;
      path = "/etc/nginx/pki/ca.crt";
      owner = "nginx";
    };
    crl-pem = {
      file = ../secrets/services/landing/crl.pem.age;
      path = "/etc/nginx/pki/crl.pem";
      owner = "nginx";
    };
  };

  services.dashy = {
    enable = true;
    settings = builtins.readFile "${toString ./../files/dashy/settings.yaml}";
    virtualHost = { 
      enableNginx = true;
      domain = "${config.networking.fqdn}";
    };
  };

  services.nginx = {
    enable = true;
    enableReload = true;
    eventsConfig = ''
      use epoll;
      worker_connections 4096;
    '';
    commonHttpConfig = ''
      # Rate limiting config
      limit_req_zone $binary_remote_addr zone=limiter:10m rate=10r/s;
    '';
    virtualHosts = {
      "${config.networking.fqdn}" = {
        forceSSL = true;
        sslCertificateKey = "/etc/nginx/ssl/server.key";
        sslCertificate = "/etc/nginx/ssl/server.crt";
        extraConfig = ''
          # Path to Certificate Authority (CA) file
          ssl_client_certificate /etc/nginx/pki/ca.crt;
          
          # Path to Certificate Revocation List (CRL) file
          ssl_crl /etc/nginx/pki/crl.pem;
            
          ssl_verify_client on;

          access_log /var/log/nginx/mtls.access.log;
          error_log /var/log/nginx/mtls.error.log;
        '';
      };

      "grafana.${domain}" = {
        forceSSL = true;
        sslCertificateKey = "/etc/nginx/ssl/server.key";
        sslCertificate = "/etc/nginx/ssl/server.crt";
        extraConfig = ''
          # Path to Certificate Authority (CA) file
          ssl_client_certificate /etc/nginx/pki/ca.crt;
          
          # Path to Certificate Revocation List (CRL) file
          ssl_crl /etc/nginx/pki/crl.pem;
            
          ssl_verify_client on;

          access_log /var/log/nginx/mtls.access.log;
          error_log /var/log/nginx/mtls.error.log;
        '';
        locations."/" = {
          proxyPass = "http://localhost:3000/";
          extraConfig = ''
            limit_req zone=limiter burst=20;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };

      "prometheus.${domain}" = {
        forceSSL = true;
        sslCertificateKey = "/etc/nginx/ssl/server.key";
        sslCertificate = "/etc/nginx/ssl/server.crt";
        extraConfig = ''
          # Path to Certificate Authority (CA) file
          ssl_client_certificate /etc/nginx/pki/ca.crt;
          
          # Path to Certificate Revocation List (CRL) file
          ssl_crl /etc/nginx/pki/crl.pem;
            
          ssl_verify_client on;

          access_log /var/log/nginx/mtls.access.log;
          error_log /var/log/nginx/mtls.error.log;
        '';      
        locations."/" = {
          proxyPass = "http://localhost:9090/";
          extraConfig = ''
            limit_req zone=limiter burst=20;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };

      "kuma.${domain}" = {
        forceSSL = true;
        sslCertificateKey = "/etc/nginx/ssl/server.key";
        sslCertificate = "/etc/nginx/ssl/server.crt";
        extraConfig = ''
          # Path to Certificate Authority (CA) file
          ssl_client_certificate /etc/nginx/pki/ca.crt;
          
          # Path to Certificate Revocation List (CRL) file
          ssl_crl /etc/nginx/pki/crl.pem;
            
          ssl_verify_client on;

          access_log /var/log/nginx/mtls.access.log;
          error_log /var/log/nginx/mtls.error.log;
        '';    
        locations."/" = {
          proxyPass = "http://localhost:8090/";
          extraConfig = ''
            limit_req zone=limiter burst=20;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
