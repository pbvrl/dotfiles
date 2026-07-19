# (Auto)Mount block devices.
{
  pkgs,
  config,
  ...
}: {
  services.udisks2.enable = true;

  systemd.user.services.automount = {
    script = builtins.readFile ../scripts_as_dotfiles/udisks/automount.sh;
    environment = {
      AUTOMOUNTABLE_SERIALS_FILE = config.sops.secrets."USUAL_USBS_SERIALS".path;
      USER_UID = toString config.users.users.${config.userDefinedGlobalVariables.username}.uid;
    };
    path = with pkgs; [
      bash
      coreutils # Provides stdbuf
      systemd # Provides udevadm
      udisks2
      libnotify
    ];
    wantedBy = ["default.target"];
    serviceConfig = {
      Restart = "always";
    };
  };
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.udisks2.filesystem-mount" &&
          subject.user == "${config.userDefinedGlobalVariables.username}") {
        return polkit.Result.YES;
      }
    });
  ''; # Allows user mounting with 'udisksctl mount --no-user-interaction'
}
