let
  markob = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2kD/iiRO/tXHo17Rj8r+BytNOUX7S/9VexcYPag/nyqiWn7Ti6A4rxc608C4taj4QpxX1kyPXhD1vdUeyA2eWulStnrDVI4ULhjb29MnVc6k9q5U4rXnuao5ksOjez3VIG0sITGFPGmr+jIlHQZLnpatdSrmh+uj3LSnPerOH7HeHBI4F9ATCtYDdW1xqStwogiaJXVNHX6lxhK/9TlPcpdkY4LbfUdQe48DjdAdN3rFnIAj8iTGL55e0bKQQRw+iqr3OyC/IGeQAPZXBsWSmJX4mIgadaf2Lo0dK4S5RbP2yOsG6eo07eZJq2bYbMoSuCpeYynNUgXF1bXBVSD0z1iC05v25sqyz6HsB843l4F6NEZnUp+DDpemWsZCCWfjouEKCMe91OmYpIt/hOLWumh/oyuSJG9kPCRQmHj5eCxcoxDPrAthJ2XM45WqKCRo7SGdXlEEhrA4iAf2874Io6fERd++bzUVtPyPF77Cgmhs3D/3TSwuUEA3T8Z1bbGU2YWf153B7Haqme3zkqswRKca5LuQ33F5eXxN/xyCEVsNiTt7F68XteNV7eAcZ5vZZ7k29iZk7iVIIJawF1ydS+5Irr79sVLIvhkzm524xGxysspSGCoI4AABYEPlNQkyfnMLtGKMpPRkAEdO1QplaalHPDP6MHIysVRGGiLZV4w== cardno:30_055_790";
  users = [ markob ];

  torvion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH87Xkji7818EWYseoHVKlpUGKdDs1iLiQ6Zks5G7a9K";
  ghosteye = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVS/OQe0b8ioVQQ7Dxa7m/EN6o48tuWXO3/xT14KvnY";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICMEw0yLnxbE2DmXW9cHc/rG0SmKDtnz8aVn2xq4O8q2";
  systems = [ torvion ghosteye ];

  all = users ++ systems;
in
{
  "users/markob/pass-hash.age"        = { publicKeys = all;                 };
  "services/nebula/ca.crt.age"        = { publicKeys = all;                 };
  "services/nebula/ca.key.age"        = { publicKeys = all;                 };
  "services/nebula/ghosteye.crt.age"  = { publicKeys = [ markob ghosteye];  };
  "services/nebula/ghosteye.key.age"  = { publicKeys = [ markob ghosteye];  };
  "services/nebula/torvion.crt.age"   = { publicKeys = [ markob torvion];   };
  "services/nebula/torvion.key.age"   = { publicKeys = [ markob torvion];   };
  "services/nebula/laptop.crt.age"    = { publicKeys = [ markob laptop];    };
  "services/nebula/laptop.key.age"    = { publicKeys = [ markob laptop];    };
  "services/landing/server.crt.age"   = { publicKeys = [ markob ghosteye ]; };
  "services/landing/server.key.age"   = { publicKeys = [ markob ghosteye ]; };
  "services/landing/ca.crt.age"       = { publicKeys = [ markob ghosteye ]; };
  "services/landing/crl.pem.age"      = { publicKeys = [ markob ghosteye ]; };
  "services/grafana/pass.age"         = { publicKeys = [ markob ghosteye ]; };
  "services/geth/jwt-secret.age"      = { publicKeys = [ markob torvion ];  };
  "services/nimbus/jwt-secret.age"    = { publicKeys = [ markob torvion ];  };
  "services/nimbus/fee-recipient.age" = { publicKeys = [ markob torvion ];  };
}
