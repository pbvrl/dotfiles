{pkgs, ...}: let
  ntfyNotify = pkgs.writeShellScript "ntfy-notify" ''
    case "$NTFY_PRIORITY" in
      1 | 2) urgency="low" ;;
      4 | 5) urgency="critical" ;;
      *) urgency="normal" ;;
    esac
    timeout=()
    case ",$NTFY_TAGS," in
      *,sticky,*) timeout=(-t 0) ;;
    esac
    exec ${pkgs.libnotify}/bin/notify-send \
      --app-name="ntfy" \
      --category="''${NTFY_TAGS:-ntfy}" \
      --urgency="$urgency" \
      "''${timeout[@]}" \
      "''${NTFY_TITLE}" "''${NTFY_MESSAGE}"
  '';
in {
  systemd.user.services.ntfy-notifications = {
    # wantedBy = ["graphical-session.target"];  # See dotfiles/river.nix
    wantedBy = ["default.target"];
    serviceConfig = {
      ExecStart = "${pkgs.ntfy-sh}/bin/ntfy subscribe http://vps/notifications ${ntfyNotify}";
      Restart = "always";
      RestartSec = 10;
    };
  };
}
