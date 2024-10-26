{ ... }:

{
  imports = [
    ../services/landing.nix
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

  services.landing = {
    enable = true;
    serverTLSCertificate = "/etc/nginx/ssl/server.crt";
    serverTLSKey         = "/etc/nginx/ssl/server.key";
    CACertificate        = "/etc/nginx/pki/ca.crt";
    CRL                  = "/etc/nginx/pki/crl.pem";
  };
}
