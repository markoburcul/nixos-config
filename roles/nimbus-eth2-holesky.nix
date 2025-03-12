{ pkgs, lib, config, ... }:

let
  services = config.services;
in {
  imports = [
    ../services/nimbus-eth2.nix
  ];

  options.nimbus = {
    network      = lib.mkOption { default = "holesky"; };
    listenPort   = lib.mkOption { default = 9802; }; # WebDAV Source TLS/SSL
    discoverPort = lib.mkOption { default = 9802; }; # WebDAV Source TLS/SSL
    #feeRecipient = lib.mkOption { default = "service/nimbus/fee-recipient"; };
    jwtSecret    = lib.mkOption { default = "services/geth/jwt-secret"; };
  };

  config = let
    cfg = config.nimbus;
  in {
    # Secrets
    age.secrets = {
      jwt-secret-nimbus = {
        file = ../secrets/services/nimbus/jwt-secret.age;
        path = "/persist/workshop/nimbus/jwt-secret";
        owner = "nimbus";
        group = "nimbus";
        mode = "440";
      };
      #fee-recipient = {
      #  file = ../secrets/services/nimbus/fee-recipient.age;
      #  path = "/persist/workshop/nimbus/fee-recipient";
      #  owner = "nimbus";
      #  group = "nimbus";
      #  mode = "440";
      #};
    };

    services.nimbus-eth2 = {
      enable = true;
      inherit (cfg) network listenPort discoverPort;
      log = { 
        level = "info"; 
        format = "json"; 
      };
      metrics = { 
        enable = true; 
        address = "0.0.0.0"; 
      };
      rest = { 
        enable = true; 
        address = "0.0.0.0"; 
      };
      history = "prune";
      dataDir = "/persist/workshop/nimbus";
      threadsNumber = 0; /* 0 == auto */
      /* Higher resource usage for small increase in rewards. */
      subAllSubnets = false;
      /* Costs two slot rewards at restart if enabled. */
      doppelganger = false;
      /* If Go-Ethereum is running use it. */
      execURLs =
        if services.erigon.enable then
        ["http://localhost:${builtins.toString services.erigon.settings.${"authrpc.port"}}/"]
        else if services.geth.${cfg.network}.enable then
        ["http://localhost:${builtins.toString services.geth.${cfg.network}.authrpc.port}/"]
        else
        [];
      jwtSecret = "/persist/workshop/nimbus/jwt-secret";
      payloadBuilder = true;
      payloadBuilderURL = services.mev-boost.listenAddr;
      localBlockValueBoost = 10;
      # TODO: enable loading variables from files using systemd
      suggestedFeeRecipient = "0xE73a3602b99f1f913e72F8bdcBC235e206794Ac8";
      extraArgs = [
        "--direct-peer=enr:-MS4QLzcHJkzjIlV0RgEg7qZsCMQ1Ja5AC3S6dxeO34OI019TxL0ccr8WoJtMB6bWEBk3mYzQ6aUAJ7b4BvnkDBe5u8Gh2F0dG5ldHOIADAAAAAAAACEZXRoMpABniGtBgFwAP__________gmlkgnY0gmlwhI6EwKaJc2VjcDI1NmsxoQOGDazxqw6ni7oD_Al6rC6M0wXSdlUzOwvk7TXP0ZNrI4hzeW5jbmV0c4gAAAAAAAAAAIN0Y3CCIzGDdWRwgiMx"
        "--direct-peer=enr:-OW4QBYApNK6qIf0GTgUyD8PylgykThXV1uonxDfW3CLAqVlf4PD_Gk_0rCQJLcB-rMjRutM0g-8PpaTwzEULwOZ3mOBjIdhdHRuZXRziP__________hmNsaWVudNiKTGlnaHRob3VzZYw3LjAuMC1iZXRhLjCEZXRoMpABniGtBgFwAP__________gmlkgnY0gmlwhLzWgw-EcXVpY4IjMolzZWNwMjU2azGhAn81iBOMXEkoExlYDJRDRdzLQrQUbZDNIV46Pmv8hn4liHN5bmNuZXRzD4N0Y3CCIyiDdWRwgiMo"
        "--direct-peer=enr:-Mq4QFuhZwXIAtXdj7DpD-KARK9Q1dPwPgfZUXr8GlqbiyEHVu4sVlbGQs7VbUjKq_fz18uhqRz-1anjrZW7SNIIIneGAZVB0eklh2F0dG5ldHOIAAAAAAAAAACEZXRoMpABniGtBwFwAP__________gmlkgnY0gmlwhE-JZV6EcXVpY4IyyIlzZWNwMjU2azGhAq9OfKYbLyFfMIaIw71_P3jiUJGg4IwiOQ2zNq8nu9YXiHN5bmNuZXRzAIN0Y3CCZIyDdWRwgmSM"
        "--direct-peer=enr:-Mq4QK_Dpg8RBDNQistboAVLLRIkI45fAGuOQ21XToMQDu5XY6mLWjbjvkl1v3ji8sOh4kxcqQFiWmwiGwA3SlmP-8OGAZVB0ekmh2F0dG5ldHOIAAAMAAAAAACEZXRoMpABniGtBwFwAP__________gmlkgnY0gmlwhE-JZV6EcXVpY4IyyIlzZWNwMjU2azGhAq9OfKYbLyFfMIaIw71_P3jiUJGg4IwiOQ2zNq8nu9YXiHN5bmNuZXRzAIN0Y3CCZIyDdWRwgmSM"
        "--direct-peer=enr:-Mq4QBMFznP2Y0OSAnC717HpqxFXOYBGxoxFun6hIGlnxPs3ZPxPG2n_10SuKnm1HylqeP19xwORGYeMt5wlhIbVc2yGAZVB0eknh2F0dG5ldHOIAAAMAAAAAACEZXRoMpABniGtBwFwAP__________gmlkgnY0gmlwhE-JZV6EcXVpY4IyyIlzZWNwMjU2azGhAq9OfKYbLyFfMIaIw71_P3jiUJGg4IwiOQ2zNq8nu9YXiHN5bmNuZXRzB4N0Y3CCZIyDdWRwgmSM"
        "--direct-peer=enr:-Mq4QHqsiFx8H0-M-tBvWS2RoRpTReX8dTpP97VAjQAIl0XwZk78Y5CPlnO6GqfTxJpbKreoaTEd6xWSCjbJ2e4JxvqGAZVB89cBh2F0dG5ldHOIAAAAAAAAAACEZXRoMpABniGtBwFwAP__________gmlkgnY0gmlwhKITZ4iEcXVpY4IyyIlzZWNwMjU2azGhAxPkpAHShflJSq9ueoJlvZ11Wf8kx2_jZpxPRf9bmJj1iHN5bmNuZXRzAIN0Y3CCZI2DdWRwgmSN"
        "--direct-peer=enr:-Mq4QHt9S30rtVarg9mYnDGTDT8013hgEenRbSnR5FmUVRbvQmqDWXLEqFKh63CxmD6NyyC0gl2RRsJ_HsEjauN2mjyGAZVB89cCh2F0dG5ldHOIAAAAAAAAAGCEZXRoMpABniGtBwFwAP__________gmlkgnY0gmlwhKITZ4iEcXVpY4IyyIlzZWNwMjU2azGhAxPkpAHShflJSq9ueoJlvZ11Wf8kx2_jZpxPRf9bmJj1iHN5bmNuZXRzAIN0Y3CCZI2DdWRwgmSN"
        "--direct-peer=enr:-Mq4QMPd9USycvu5i17_27pxQqlfwablXbrFvFmzENwm9mwuHz7OZySPHKTyVWqUpuONN9JkTPA6ZfLlHBIpdg4c_DOGAZVB89cDh2F0dG5ldHOIAAAAAAAAAGCEZXRoMpABniGtBwFwAP__________gmlkgnY0gmlwhKITZ4iEcXVpY4IyyIlzZWNwMjU2azGhAxPkpAHShflJSq9ueoJlvZ11Wf8kx2_jZpxPRf9bmJj1iHN5bmNuZXRzDYN0Y3CCZI2DdWRwgmSN"
        "--direct-peer=enr:-PW4QEMiELi7PvcwVnp7_Z-nYxI6a-xxMAzPYNF-GyypU_oxP5EctJ1KoRYYpMI39OXhjOHw05xfqt3itCV43Xg-VX4-h2F0dG5ldHOIAABgAAAAAACGY2xpZW502IpMaWdodGhvdXNljDcuMC4wLWJldGEuMYRldGgykAGeIa0GAXAA__________-CaWSCdjSCaXCEoSMSVYRxdWljgiMphXF1aWM2giMpiXNlY3AyNTZrMaECuricZJbHZTzcTBteRRNZNSM2nZqhic9Aklr372MwSaSIc3luY25ldHMOg3RjcIIjKIR0Y3A2giMog3VkcIIjKA"
        "--direct-peer=enr:-MS4QHL1sj-eOU2LjyhIqQF4zFKwbObRlKHtcBbW18fvYgSkTK32pRVcH6pq6eZUwC_7wA2dkKnwys6zjuB4iZCVKEoOh2F0dG5ldHOIAAMAAAAAAACEZXRoMpABniGtBgFwAP__________gmlkgnY0gmlwhE309baJc2VjcDI1NmsxoQLzp3Y_30qtidiDzXc151CrYpRPTLieUtP_xeRD2vOPt4hzeW5jbmV0c4gAAAAAAAAAAIN0Y3CCIyiDdWRwgiMo"
        "--direct-peer=enr:-PW4QAOnzqnCuwuNNrUEXebSD3MFMOe-9NApsb8UkAQK-MquYtUhj35Ksz4EWcmdB0Cmj43bGBJJEpt9fYMAg1vOHXobh2F0dG5ldHOIAAAYAAAAAACGY2xpZW502IpMaWdodGhvdXNljDcuMC4wLWJldGEuMIRldGgykAGeIa0GAXAA__________-CaWSCdjSCaXCEff1tSYRxdWljgiMphXF1aWM2giMpiXNlY3AyNTZrMaECUiAFSBathSIPGhDHbZjQS5gTqaPcRkAe4HECCk-vt6KIc3luY25ldHMPg3RjcIIjKIR0Y3A2giMog3VkcIIjKA"
        "--direct-peer=enr:-QESuEA2tFgFDu5LX9T6j1_bayowdRzrtdQcjwmTq_zOVjwe1WQOsM7-Q4qRcgc7AjpAQOcdb2F3wyPDBkbP-vxW2dLgXYdhdHRuZXRziAADAAAAAAAAhmNsaWVudNiKTGlnaHRob3VzZYw3LjAuMC1iZXRhLjCEZXRoMpABniGtBgFwAP__________gmlkgnY0gmlwhIe1ME2DaXA2kCoBBPkwgDCeAAAAAAAAAAKEcXVpY4IjKYVxdWljNoIjg4lzZWNwMjU2azGhA4oHjOmlWOfLizFFIQSI_dzn4rzvDvMG8h7zmxhmOVzXiHN5bmNuZXRzD4N0Y3CCIyiEdGNwNoIjgoN1ZHCCIyiEdWRwNoIjgg"
        "--direct-peer=enr:-OS4QKFOnMcxRM0fQEaceMxCcIYmvYevFRZEkdaTvznPAseqMeJ12MOV2hAwcBNlSih5N35Z7C2bLyfqrfWiAsYCFSsOh2F0dG5ldHOIAAAAAABgAACGY2xpZW502IpMaWdodGhvdXNljDcuMC4wLWJldGEuMIRldGgykAGeIa0GAXAA__________-CaWSCdjSCaXCEOYFTmIRxdWljgiMpiXNlY3AyNTZrMaEDIWabl1TwLiuVYEPyY3awYu2uPrVV2j1aMJDhRETmZlOIc3luY25ldHMAg3RjcIIfaIN1ZHCCH2g"
        "--direct-peer=enr:-OS4QERlcPEBHVDfmK8vhzmOrVCuu4qW5ZjVRcbuw1aIJpFkRI80Eeha0UergDtYXHQtkvowptcE5kw0MUVoUlEGJq4Vh2F0dG5ldHOIAAAAABgAAACGY2xpZW502IpMaWdodGhvdXNljDcuMC4wLWJldGEuMIRldGgykAGeIa0GAXAA__________-CaWSCdjSCaXCElohZI4RxdWljgiMpiXNlY3AyNTZrMaEDb8nvcnLLwOezQSv7lvfgBknrTMTQeuKwDjLiYk-UF_uIc3luY25ldHMAg3RjcIIjKIN1ZHCCIyg"
        "--direct-peer=enr:-OS4QEd53pg8rGroM0j5IA87LxGCunYRb1HsXCnmdtzJgaGWILps0Etjq98VcDF3qOoodwvSBgwwNzggTiN4v-JudFoVh2F0dG5ldHOIAAAAAACAAQCGY2xpZW502IpMaWdodGhvdXNljDcuMC4wLWJldGEuMIRldGgykAGeIa0GAXAA__________-CaWSCdjSCaXCElojti4RxdWljgiMpiXNlY3AyNTZrMaEDVF_0pgew6168E9_U0UCfQeYD7LBXh1LLqXXhwDL1-3OIc3luY25ldHMAg3RjcIIjKIN1ZHCCIyg"
        "--direct-peer=enr:-OS4QEbuvPjAtgtQ_y44C8BqLv5eMHpk49_FWFUamWlCS2KdOdzklt0J6H6D6erjOjVbWjGmZBImZBBDv5bXibHxLrwZh2F0dG5ldHOIAAAAABgAAACGY2xpZW502IpMaWdodGhvdXNljDcuMC4wLWJldGEuMIRldGgykAGeIa0GAXAA__________-CaWSCdjSCaXCElohZI4RxdWljgiMpiXNlY3AyNTZrMaEDb8nvcnLLwOezQSv7lvfgBknrTMTQeuKwDjLiYk-UF_uIc3luY25ldHMAg3RjcIIjKIN1ZHCCIyg"
        "--direct-peer=enr:-OS4QIInH82PSXknMPck3ppPuGyjUceJp0v0RmsM-j5URu_IO-k98TyYj1xlZvWFe1hOJRw2z6-BVJt34Cmne2Joy7AQh2F0dG5ldHOIAAAAAwAAAACGY2xpZW502IpMaWdodGhvdXNljDcuMC4wLWJldGEuMIRldGgykAGeIa0GAXAA__________-CaWSCdjSCaXCENJIlc4RxdWljgiMpiXNlY3AyNTZrMaED9xzAXSximv688LPAr585cSyZ5eyk-uAi_unEp12PN6CIc3luY25ldHMPg3RjcIIjKIN1ZHCCIyg"
      ];
    };

    systemd.tmpfiles.rules = [
      "d /persist/workshop/nimbus 700 nimbus nimbus"
      "d /persist/workshop/nimbus/era 700 nimbus nimbus"
    ];

    users.users.nimbus.uid = 5000;
    users.groups.nimbus.gid = 5000;

    systemd.services.nimbus-eth2 = {
      serviceConfig = {
        Nice = -20;
        IOSchedulingClass = "realtime";
        IOSchedulingPriority = 0;
        DynamicUser = lib.mkForce false;
        User = "nimbus";
        Group = "nimbus";
      };
    };

    # Firewall
    networking.firewall.allowedTCPPorts = [ cfg.listenPort ];
    networking.firewall.allowedUDPPorts = [ cfg.discoverPort ];
  };
}
