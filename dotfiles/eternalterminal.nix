{...}: {
  config.services.eternal-terminal.enable = true;
  config.systemd.services.eternal-terminal.serviceConfig.PIDFile = "/run/etserver.pid";
}
