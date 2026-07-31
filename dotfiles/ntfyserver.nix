{config, ...}: {
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "http://${config.networking.hostName}";
      listen-http = "0.0.0.0:80";
    };
  };
}
