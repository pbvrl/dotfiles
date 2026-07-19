{
  config,
  pkgs,
  lib,
  ...
}: let
  username = config.userDefinedGlobalVariables.username;
  sopsKeyPath = /home/nixos/.config/secretkey/sops_private_key.txt;
  hasSopsKey = builtins.pathExists sopsKeyPath;
in {
  systemd.services.populate-dotfiles = {
    description = "Copy the config repo to the live iso and run gnu stow";
    wantedBy = ["multi-user.target"];
    before = ["display-manager.service"];
    path = [pkgs.bash pkgs.coreutils pkgs.stow pkgs.util-linux];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      home=/home/${username}
      repo="$home/.config/nixos"
      if [ ! -e "$repo" ]; then
        mkdir -p "$home/.config"
        cp -a ${../..} "$repo"
        chmod -R u+w "$repo"
        chown -R ${username}:users "$home/.config"
      fi
      runuser -u ${username} -- env HOME="$home" bash "$repo/scripts/stow.sh"
    '';
  };
  system.activationScripts.copySopsKey = lib.mkIf hasSopsKey (lib.stringAfter ["specialfs"] ''
    install -D -m 0400 -o ${username} -g users ${sopsKeyPath} /home/${username}/.config/secretkey/sops_private_key.txt
  '');
  system.activationScripts.setupSecrets.deps = lib.mkIf hasSopsKey ["copySopsKey"];
}
