{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo122Module ( args // rec {
    version = "1.14.13";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-oJe+V11WArXVmoIC7nYN6oKc0VoHtRtelidyb3v6skI=";
    };

    vendorHash = "sha256-IEwy3XRyj+5GjAWRjPsd5qzwEMpI/pZIwPjKdeATgkE=";

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
