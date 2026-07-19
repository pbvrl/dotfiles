# tpm unlock enabled disk swap attack prevention
# https://oddlama.org/blog/bypassing-disk-encryption-with-tpm2-unlock/
# https://giggio.net/en/blog/nix-os-guia-de-instalacao-com-raid-1-criptografia-e-tpm-unlock-parte-6-mitigando-o-ataque-de-troca-de-volume/
{
  lib,
  pkgs,
  ...
}: let
  pcr15 = null; # 64-char sha256 hex string; null = measure but don't check yet
in {
  boot.initrd.luks.devices.encrypted_disk.crypttabExtraOpts = [
    "tpm2-device=auto" # tpm unlock - unused
    "tpm2-measure-pcr=yes" # attack mitigation
  ];

  boot.initrd.systemd.extraBin.jq = lib.getExe pkgs.jq;
  boot.initrd.systemd.services.check-pcrs = lib.mkIf (pcr15 != null) {
    script = ''
      echo "Checking PCR 15 value"
      if [[ $(systemd-analyze pcrs 15 --json=short | jq -r ".[0].sha256") != "${pcr15}" ]]; then
        echo "PCR 15 check failed"
        exit 1
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    unitConfig.DefaultDependencies = "no";
    after = ["cryptsetup.target"];
    before = ["sysroot.mount"];
    requiredBy = ["sysroot.mount"];
  };
}
# If using tpm-unlock and allowing microsoft keys (which is done by default) then also check this:
# https://giggio.net/en/blog/nix-os-guia-de-instalacao-com-raid-1-criptografia-e-tpm-unlock-parte-7-mitigando-o-ataque-de-troca-de-so/tpm

