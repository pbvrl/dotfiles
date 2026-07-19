{pkgs, ...}: {
  services.xserver = {
    enable = true;
    videoDrivers = ["nvidia"];
  };
  hardware.graphics.enable = true;
  hardware.nvidia = {
    nvidiaSettings = true;
    modesetting.enable = true;
    open = false;
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  # hardware.nvidia-container-toolkit.enable = true;
  nixpkgs.config.cudaSupport = true;
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
  ];
  environment.variables = {
    LD_LIBRARY_PATH = "${pkgs.linuxPackages.nvidia_x11}/lib";
    JAX_PLATFORMS = "cuda,cpu";
  };
}
