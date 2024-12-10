{ 
  config, 
  pkgs,
  lib,
  ... 
}:
let
  relays = [ 
    "https://0xb1559beef7b5ba3127485bbbb090362d9f497ba64e177ee2c8e7db74746306efad687f2cf8574e38d70067d40ef136dc@relay-stag.ultrasound.money/"
    "https://0xab78bf8c781c58078c3beb5710c57940874dd96aef2835e7742c866b4c7c0406754376c2c8285a36c630346aa5c5f833@holesky.aestus.live"
    "https://0x821f2a65afb70e7f2e820a925a9b4c80a159620582c1766b1b09729fec178b11ea22abb3a51f07b288be815a1a2ff516@bloxroute.holesky.blxrbdn.com"
    "https://0xaa58208899c6105603b74396734a6263cc7d947f444f396a90f7b7d3e65d102aec7e5e5291b27e08d02c50a050825c2f@holesky.titanrelay.xyz/"
    "https://0xafa4c6985aa049fb79dd37010438cfebeb0f2bd42b115b89dd678dab0670c1de38da0c4e9138c9290a398ecd9a0b3110@boost-relay-holesky.flashbots.net"
  ];
in
{
  imports = [
    ../services/mev-boost.nix
  ];

  services.mev-boost = {
    enable = true;
    listenAddr = "0.0.0.0:18550";
    holesky = true;
    loglevel = "info";
    minBid = 0.05;
    relayCheck = true;
    relays = lib.concatStringsSep "," relays;
    service.user = "mev-boost";
  };
}