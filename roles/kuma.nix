{ 
  pkgs,
  lib,
  ... 
}:
{
  services.uptime-kuma= {
    enable = true;
    settings = {
      HOST     = "127.0.0.1";
      PORT     = "8090";
    };
  };
}