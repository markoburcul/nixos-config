{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo123Module ( args // rec {
    version = "1.15.3";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-G1xnIF9cF8xrEam/N3Y65odJS0yAf2F0vhtAwHQSfsQ=";
    };

    vendorHash = "sha256-psICCT8FNye/i76RDcCAr+mCt27qzO/qzG+PBjvbs88=";

    proxyVendor = true;

    doCheck = false;

    subPackages = [
      "cmd/ethkey"
      "cmd/clef"
      "cmd/geth"
      "cmd/utils"
    ];
  });
}
