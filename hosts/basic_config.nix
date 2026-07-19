{
  config,
  pkgs,
  ...
}: {
  # Timezone
  config.time.timeZone = "Europe/Madrid";

  # Username and  groups
  config.users.users.${config.userDefinedGlobalVariables.username} = {
    isNormalUser = true;
    extraGroups = ["wheel" "audio" "video" "dialout" "networkmanager" "docker" "input" "uinput"];
  };

  # Locale
  config.i18n.defaultLocale = "en_US.UTF-8";
  config.i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Audio, video
  config.security.rtkit.enable = true;
  config.services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };

  # Battery
  config.services.power-profiles-daemon.enable = false;
  config.services.tlp = {
    enable = true;
    settings = {
      # CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "power";
      # CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;
    };
  };

  # Docker
  config.virtualisation.docker.enable = true;

  # Enable flakes
  config.nix.settings.experimental-features = ["nix-command" "flakes"];

  # Fonts
  config.fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # Western
      hack-font
      # East asian
      noto-fonts
      noto-fonts-cjk-sans
      # Icons
      papirus-icon-theme
      noto-fonts-color-emoji
    ];
  };

  # Garbage collection
  config.nix.gc = {
    automatic = true;
    dates = "03:05";
    options = "--delete-older-than 15d";
  };
  config.nix.optimise = {
    automatic = true;
    dates = ["03:20"];
  };

  # Graphics
  config.hardware.graphics.enable = true;

  # Add ~/.local/bin to PATH
  config.environment.localBinInPath = true;

  # Xdg
  config.xdg = {
    mime.enable = true;
    portal = {
      config.common.default = "*";
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        kdePackages.xdg-desktop-portal-kde
        xdg-desktop-portal-gtk
      ];
    };
  };

  # Stuff needed for Wayland. The name is misleading, it includes things for both X11 and Wayland. Last time I checked it hadn't been deprecated because of backwards compatiblity.
  config.services.xserver.enable = true;
  # # Disable X11 libraries: Does not work yet
  # config.environment.noXlibs = true;
  # nixpkgs.config.packageOverrides = pkgs: {
  #   pipewire = pkgs.pipewire.override { x11Support = false; };
  # };

  # No password
  config.security.sudo.wheelNeedsPassword = false; # wheel group users don't need password

  # Bluetooth
  config.hardware.bluetooth.enable = false;
  config.hardware.bluetooth.powerOnBoot = false;
  config.services.blueman.enable = false;

  # Printing
  config.services.printing.enable = true;

  # State version - Different from the nixpkgs version specified at flake.nix.
  # WARNING: Avoid changing it unless you've read the nixos docs/wiki on it.
  config.system.stateVersion = "24.11";
}
