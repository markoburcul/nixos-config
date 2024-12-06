{ pkgs, config, ... }:

{
  # Give extra permissions with Nix
  nix.settings.trusted-users = [ "markob" ];

  age.secrets."users/markob/pass-hash" = {
    file = ../secrets/users/markob/pass-hash.age;
  };

  users.groups.markob = {
    gid = 1000;
    name = "markob";
  };

  # Define a user account.
  users.users.markob = {
    description = "Marko Burcul";
    uid = 1000;
    createHome = true;
    isNormalUser = true;
    useDefaultShell = true;
    group = "markob";
    hashedPasswordFile = config.age.secrets."users/markob/pass-hash".path;
    extraGroups = [
      "wheel" "audio" "disk" "adm" "tty"
      "systemd-journal" "docker" "networkmanager"
      "nimbus" "geth-holesky" "prometheus" "grafana"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2kD/iiRO/tXHo17Rj8r+BytNOUX7S/9VexcYPag/nyqiWn7Ti6A4rxc608C4taj4QpxX1kyPXhD1vdUeyA2eWulStnrDVI4ULhjb29MnVc6k9q5U4rXnuao5ksOjez3VIG0sITGFPGmr+jIlHQZLnpatdSrmh+uj3LSnPerOH7HeHBI4F9ATCtYDdW1xqStwogiaJXVNHX6lxhK/9TlPcpdkY4LbfUdQe48DjdAdN3rFnIAj8iTGL55e0bKQQRw+iqr3OyC/IGeQAPZXBsWSmJX4mIgadaf2Lo0dK4S5RbP2yOsG6eo07eZJq2bYbMoSuCpeYynNUgXF1bXBVSD0z1iC05v25sqyz6HsB843l4F6NEZnUp+DDpemWsZCCWfjouEKCMe91OmYpIt/hOLWumh/oyuSJG9kPCRQmHj5eCxcoxDPrAthJ2XM45WqKCRo7SGdXlEEhrA4iAf2874Io6fERd++bzUVtPyPF77Cgmhs3D/3TSwuUEA3T8Z1bbGU2YWf153B7Haqme3zkqswRKca5LuQ33F5eXxN/xyCEVsNiTt7F68XteNV7eAcZ5vZZ7k29iZk7iVIIJawF1ydS+5Irr79sVLIvhkzm524xGxysspSGCoI4AABYEPlNQkyfnMLtGKMpPRkAEdO1QplaalHPDP6MHIysVRGGiLZV4w== openpgp:0xCC75A7BC"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2kD/iiRO/tXHo17Rj8r+BytNOUX7S/9VexcYPag/nyqiWn7Ti6A4rxc608C4taj4QpxX1kyPXhD1vdUeyA2eWulStnrDVI4ULhjb29MnVc6k9q5U4rXnuao5ksOjez3VIG0sITGFPGmr+jIlHQZLnpatdSrmh+uj3LSnPerOH7HeHBI4F9ATCtYDdW1xqStwogiaJXVNHX6lxhK/9TlPcpdkY4LbfUdQe48DjdAdN3rFnIAj8iTGL55e0bKQQRw+iqr3OyC/IGeQAPZXBsWSmJX4mIgadaf2Lo0dK4S5RbP2yOsG6eo07eZJq2bYbMoSuCpeYynNUgXF1bXBVSD0z1iC05v25sqyz6HsB843l4F6NEZnUp+DDpemWsZCCWfjouEKCMe91OmYpIt/hOLWumh/oyuSJG9kPCRQmHj5eCxcoxDPrAthJ2XM45WqKCRo7SGdXlEEhrA4iAf2874Io6fERd++bzUVtPyPF77Cgmhs3D/3TSwuUEA3T8Z1bbGU2YWf153B7Haqme3zkqswRKca5LuQ33F5eXxN/xyCEVsNiTt7F68XteNV7eAcZ5vZZ7k29iZk7iVIIJawF1ydS+5Irr79sVLIvhkzm524xGxysspSGCoI4AABYEPlNQkyfnMLtGKMpPRkAEdO1QplaalHPDP6MHIysVRGGiLZV4w== openpgp:0xCC75A7BC"
  ];

  # allow of sudo without password
  security.sudo.wheelNeedsPassword = false;
}
