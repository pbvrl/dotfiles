# (Auto)Mount block devices.
{
  pkgs,
  config,
  ...
}: {
  services.udisks2.enable = true;

  users.users.usbAutomount = {
    isSystemUser = true;
    group = "usbAutomount";
  };
  users.groups.usbAutomount = {};

  systemd.services.automount = {
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
    ];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Restart = "always";
      User = "usbAutomount";
    };
  };
  # Allows mounting with 'udisksctl mount --no-user-interaction' to the user and the automount service
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.udisks2.filesystem-mount" &&
          (subject.user == "${config.userDefinedGlobalVariables.username}" ||
           subject.user == "usbAutomount")) {
        return polkit.Result.YES;
      }
    });
  '';
}
