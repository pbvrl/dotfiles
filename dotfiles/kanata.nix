# Keyboard remapper
{pkgs, ...}: {
  services.kanata = {
    package = pkgs.kanata-with-cmd;
    enable = true;
    keyboards.default = {
      devices = [];
      config = builtins.readFile ./kanata/kanata.kbd;
      extraDefCfg = "
        process-unmapped-keys yes ;; unspecified keys
        movemouse-smooth-diagonals yes
        movemouse-inherit-accel-state yes
      ";
    };
  };

  # To find a keyboard name:
  # nix-shell p usbutils
  # lsusb
  # Then:
  # services.udev.extraRules = ''
  #   KERNEL=="event*", SUBSYSTEM=="input", ATTRS{name}=="keyclicks w-corne-choc(STM32) Keyboard", SYMLINK+="input/corne"
  # '';
}
