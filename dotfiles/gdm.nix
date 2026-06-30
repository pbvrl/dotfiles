# Display manager a.k.a Login manager (Logging in manager)
{
  config,
  pkgs,
  ...
}: {
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = config.userDefinedGlobalVariables.username;
    gdm = {
      enable = true;
      wayland = true;

      # Be able to select Sway if River breaks.
      autoLogin.delay = 5;
    };
    sessionPackages = [
      pkgs.river-classic
      # Sway by default binds Super+Enter to foot.
      pkgs.sway
    ];

    defaultSession = "river";
  };
}
