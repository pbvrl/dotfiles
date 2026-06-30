# Decrypts and exposes sops secrets to nixos.
{config, ...}: let
  user = "${config.userDefinedGlobalVariables.username}";
in {
  config.sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/home/${user}/.config/secretkey/sops_private_key.txt";
    defaultSopsFormat = "yaml";
    secrets = {
      # RESTIC_REPO_PASSWORD = {owner = user;};
      ANTHROPIC_API_KEY = {owner = user;};
      OPENROUTER_API_KEY = {owner = user;};
      VPS_API_KEY = {owner = user;};
      USUAL_USBS_SERIALS = {owner = user;}; # Find out by plugging it in while running `udevadm monitor --property --udev -s block`
      "git/USER_NAME" = {owner = user;};
      "git/USER_EMAIL" = {owner = user;};
    };
  };
}
# WARNING: The owner can also access them at /run/secrets/$SECRET
# TODO: Figure out why it is more secure to provide the secrets through systemd services.
# owner = "secretsService";

