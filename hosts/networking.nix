{
  config.networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      interfaces.tailscale0.allowedTCPPorts = [22];
    };
  };
  config.services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  config.services.tailscale = {
    enable = true;
    openFirewall = true;
  };
}
