{ pkgs, ... }:
{
  services.loki= {
    enable = true;
    configFile = ../files/loki/config.yml;
    };
}