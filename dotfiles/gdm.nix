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
      # Be able to select Sway if there's a problem within River
      autoLogin.delay = 5;
    };
    sessionPackages = [
      pkgs.river-classic
      # Sway by default binds `foot` to Super+Enter
      pkgs.sway
    ];
    defaultSession = "river";
  };
}
