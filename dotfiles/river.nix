# Related to https://github.com/emersion/mako/issues/636
# I was using a systemd service to launch mako so that the LLM had an easier time debugging through journalctl
# I went back to doing 'riverctl spawn "mako"'
{
  systemd.user.targets.river-session = {
    bindsTo = ["graphical-session.target"];
  };
}
