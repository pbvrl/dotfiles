{
  config,
  pkgs,
  ...
}: let
  sessions = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
  autologinDelay = 7;
  autologin = pkgs.writeShellScript "autologin" ''
    printf '\033[2J\033[H'
    echo "Starting River in ${toString autologinDelay} seconds. Press c for river-classic, s for Sway, any other key for tuigreet."
    if read -r -s -n 1 -t ${toString autologinDelay} key; then
      [ "$key" = c ] && exec ${pkgs.river-classic}/bin/river
      [ "$key" = s ] && exec sway
      exit
    fi
    exec river-rijan
  '';
in {
  services.displayManager.sessionPackages = [
    pkgs.rijan
    pkgs.river-classic
    # Sway by default binds `foot` to Super+Enter
    pkgs.sway
  ];
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      initial_session = {
        command = "${autologin}";
        user = config.userDefinedGlobalVariables.username;
      };
      default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions ${sessions}";
    };
  };
}
