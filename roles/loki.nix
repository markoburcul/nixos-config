{ 
  pkgs,
  lib,
  ... 
}:
let
  # Informative
  listenPort = 3030;
in {
  services.loki= {
    enable = true;
    # The ports along with other items are defined inside this config file
    configFile = ../files/loki/config.yml;
  };
}