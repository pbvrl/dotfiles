# BEFORE FORMATTING, write the LUKS passphrase to the installer's tmpfs
# echo -n "yourEncryptionPassword" > /tmp/luks-password.txt
# It is only read at formatting time
{
  disko.devices = {
    disk = {
      disk1 = {
        type = "disk";
        device = "/dev/nvme0n1"; # ADJUST to the real device "lsblk -pd"
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              label = "EFI";
              content = {
                type = "filesystem";
                format = "vfat";
                extraArgs = ["-n" "EFI"];
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            encrypted_disk = {
              size = "100%";
              label = "LUKS";
              content = {
                type = "luks";
                name = "encrypted_disk";
                extraFormatArgs = ["--label" "LUKS"];
                passwordFile = "/tmp/luks-password.txt";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = ["--label" "NIXOS"];
                  subvolumes = {
                    "/@" = {mountpoint = "/";};
                    "/@home" = {mountpoint = "/home";};
                    "/@root" = {mountpoint = "/root";};
                    "/@nix" = {mountpoint = "/nix";};
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
