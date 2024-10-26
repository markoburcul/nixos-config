{ lib, config, ... }:

let
  inherit (config) services;

  default = { netdata = 9000; };

  genScrapeJob = { name, path, port }: { 
    job_name = name;
    metrics_path = path;
    scrape_interval = "60s";
    scheme = "http";
    params = { format = [ "prometheus" ]; };
    static_configs = [{ 
      targets = ["127.0.0.1:${toString port}"];
    }];
  };
in {
  services.prometheus = {
    enable = true;
    port = 9090;
    checkConfig = true;
    extraFlags = [
      "--storage.tsdb.retention.size=40GB"
      "--web.external-url=http://${config.networking.fqdn}/prometheus/"
      "--web.route-prefix=/"
    ];

    globalConfig = {
      scrape_interval = "10s";
      scrape_timeout = "5s";
    };

    scrapeConfigs = [
      (genScrapeJob {name = "netdata";  path = "/api/v1/allmetrics";        port = 9000;  })
      (genScrapeJob {name = "nimbus";   path = "/metrics";                  port = 9100;  })
      (genScrapeJob {name = "geth";     path = "/debug/metrics/prometheus"; port = 16060; })
    ];

    #ruleFiles = [
    #  ../files/prometheus/rules/netdata.yml
    #  ../files/prometheus/rules/smartctl.yml
    #  ../files/prometheus/rules/nimbus.yml
    #];
  };

  #services.landing = {
  #  proxyServices = [{
  #    name ="/prometheus/";
  #    title = "Prometheus";
  #    value = {
  #      proxyPass = "http://localhost:${toString services.prometheus.port}/";
  #    };
  #  }];
  #};
}
