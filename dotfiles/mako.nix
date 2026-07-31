# Related to https://github.com/emersion/mako/issues/636
# I was using a systemd service to launch mako so that the LLM had an easier time debugging through journalctl
# I went back to doing 'riverctl spawn "mako"'
{pkgs, ...}: {
  systemd.user.services.mako = {
    wantedBy = ["graphical-session.target"];
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];
    # This systemd service required a workaround of its own, based on the LLM:
    # "Something activates mako over D-Bus before river/init imports
    # WAYLAND_DISPLAY, so it exits with "failed to create display". Without this
    # the retries exhaust systemd's start limit in one second and it gives up."
    unitConfig.StartLimitIntervalSec = 0;
    serviceConfig = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.mako}/bin/mako";
      ExecReload = "${pkgs.mako}/bin/makoctl reload";
      Restart = "always";
      RestartSec = 2;
    };
  };
}
