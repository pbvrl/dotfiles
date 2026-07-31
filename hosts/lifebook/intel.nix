# Beware, I copy-pasted these from github repos.
{pkgs, ...}: {
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };
  environment.variables = {LIBVA_DRIVER_NAME = "iHD";};
}
