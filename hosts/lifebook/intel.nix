# Beware, I copy-pasted these from github repos.
{pkgs, ...}: {
  nixpkgs.config.ppackageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override {enableHybridCodec = true;};
  };
  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };
  environment.variables = {LIBVA_DRIVER_NAME = "iHD";};
}
