# Beware, I copy-pasted these from github repos.
{pkgs, ...}: {
  boot.initrd.kernelModules = ["amdgpu"];
  services.xserver = {
    enable = true;
    videoDrivers = ["amdgpu"];
  };
  hardware.graphics.enable = true;
  environment.systemPackages = with pkgs; [
    mesa.drivers
    libva
    libva-utils
  ];
  environment.variables = {
    LIBVA_DRIVER_NAME = "radeonsi";
  };
}
