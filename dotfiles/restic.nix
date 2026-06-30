# Automatic backups
{config, ...}: let
  user = "${config.userDefinedGlobalVariables.username}";
in {
  services.restic.backups = {
    restic-repo = {
      user = "${user}";
      initialize = false;
      repository = "/home/${user}/restic-repo";
      passwordFile = config.sops.secrets."RESTIC_REPO_PASSWORD".path;
      paths = [
        "/home/${user}/projects"
        "/home/${user}/notes"
        "/home/${user}/.config/nixos"
        "/home/${user}/.config/sops_private_key.txt"
      ];
      pruneOpts = [
        "--keep-daily 3"
        "--keep-weekly 3"
        "--keep-yearly 1"
      ];
      extraBackupArgs = [
        "--exclude='*/.venv'"
        "--exclude='*/node_modules'"
        "--exclude='*.iso'"
        "--compression max"
      ];
      timerConfig = {
        OnCalendar = "12:00";
        RandomizedDelaySec = "5h";
      };
    };
  };
}
