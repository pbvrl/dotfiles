# secureboot via lanzaboote
# requires the firmware to be in "setup mode" at install time (secureboot disabled, keys deleted)
{
  lib,
  pkgs,
  ...
}: {
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.systemd.enable = true; # systemd-based initrd; also a requirement for any future TPM unlock
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    configurationLimit = 8;
    autoGenerateKeys.enable = true;
    autoEnrollKeys = {
      enable = true;
      autoReboot = true; # enrolls the keys on the first reboot
    };
  };
  environment.systemPackages = [pkgs.sbctl];
}
