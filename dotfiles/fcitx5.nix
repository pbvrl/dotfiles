# Handles keyboard languages
{pkgs, ...}: {
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-rime
        fcitx5-mozc
        qt6Packages.fcitx5-chinese-addons
      ];
    };
  };
}
