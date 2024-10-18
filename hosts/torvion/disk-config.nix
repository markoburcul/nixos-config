{
  disko.devices = {
    disk = {
      one = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            BOOT = {
              name = "boot";
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              size = "4G";
              content = {
                type = "swap";
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
      two = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        mode = "mirror";
        # Workaround: cannot import 'zroot': I/O error in disko tests
        options.cachefile = "none";
        rootFsOptions = {
          acltype = "posixacl";
          dnodesize = "auto";
          normalization="formD";
          atime = "off";
          xattr = "sa";
          compression = "zstd";
          mountpoint = "legacy";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = "/";
        postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot@blank$' || zfs snapshot zroot@blank";

        datasets = {
          zfs_nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
          zfs_root_fs = {
            type = "zfs_fs";
            mountpoint = "/root";
          };
          zfs_home_fs = {
            type = "zfs_fs";
            mountpoint = "/home";
          };
          zfs_persist_fs = {
            type = "zfs_fs";
            mountpoint = "/persist";
            mountOptions = [
              "noatime"
            ];
          };
        };
      };
    };
  };
}