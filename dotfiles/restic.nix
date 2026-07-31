# Automatic backups
{
  config,
  pkgs,
  lib,
  ...
}: let
  user = "${config.userDefinedGlobalVariables.username}";
in {
  users.users.resticAutobackup = {
    isSystemUser = true;
    group = "resticAutobackup";
  };
  users.groups.resticAutobackup = {};

  services.restic.backups = {
    restic-repo = {
      user = "resticAutobackup";
      initialize = false;
      repository = "/home/${user}/restic-repo";
      passwordFile = config.sops.secrets."RESTIC_REPO_PASSWORD".path;
      paths = [
        "/home/${user}/projects"
        "/home/${user}/notes"
        "/home/${user}/.config/nixos"
        "/var/lib/sops-nix/key.txt"
      ];
      pruneOpts = [
        "--keep-daily 5"
        "--keep-weekly 3"
        "--keep-monthly 4"
        "--keep-yearly 3"
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
  # Grants the service access to the directories it backs up.
  # Also grants user access, so that manual scripts work.
  system.activationScripts.resticAutobackupAcl = lib.stringAfter ["users"] ''
    acl=${pkgs.acl}/bin/setfacl
    [ -d /home/${user} ] && $acl -m u:resticAutobackup:x /home/${user}
    [ -d /home/${user}/projects ]      && $acl -R -m u:resticAutobackup:rX /home/${user}/projects
    [ -d /home/${user}/.config/nixos ] && $acl -R -m u:resticAutobackup:rX /home/${user}/.config/nixos
    if [ -d /home/${user}/notes ]; then
      $acl -R    -m u:resticAutobackup:rX /home/${user}/notes
      $acl -R -d -m u:resticAutobackup:rX /home/${user}/notes
    fi
    if [ -d /home/${user}/restic-repo ]; then
      $acl -R    -m u:resticAutobackup:rwX /home/${user}/restic-repo
      $acl -R -d -m u:resticAutobackup:rwX /home/${user}/restic-repo
      # User access
      $acl -R    -m u:${user}:rwX /home/${user}/restic-repo
      $acl -R -d -m u:${user}:rwX /home/${user}/restic-repo
    fi
    [ -f /var/lib/sops-nix/key.txt ] && $acl -m u:resticAutobackup:r /var/lib/sops-nix/key.txt
    # User access
    [ -f /var/lib/sops-nix/key.txt ] && $acl -m u:${user}:r /var/lib/sops-nix/key.txt
  '';
}
