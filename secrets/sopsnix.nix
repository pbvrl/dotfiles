# Decrypts and exposes sops secrets to nixos.
{config, ...}: let
  user = "${config.userDefinedGlobalVariables.username}";
in {
  config.sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    defaultSopsFormat = "yaml";
    secrets = {
      RESTIC_REPO_PASSWORD = {owner = "resticAutobackup";};
      ANTHROPIC_API_KEY = {owner = user;};
      OPENROUTER_API_KEY = {owner = user;};
      VPS_API_KEY = {owner = user;};
      USUAL_USBS_SERIALS = {owner = "usbAutomount";};
      "git/USER_NAME" = {owner = user;};
      "git/USER_EMAIL" = {owner = user;};
    };
  };
}
