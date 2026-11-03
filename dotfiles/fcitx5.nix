# Handles keyboard languages
{pkgs, ...}: {
  # Fix for fcitx5-mozc, allows for typing japanese
  nixpkgs.overlays = [
    (final: prev: {
      mozc = prev.mozc.overrideAttrs (old: {
        postPatch =
          (old.postPatch or "")
          + ''
            substituteInPlace src/gui/dictionary_tool/dictionary_tool.ui \
              --replace-fail '"::mozc::gui::DictionaryContentTableWidget"' '"mozc::gui::DictionaryContentTableWidget"' \
              --replace-fail '<class>::mozc::gui::DictionaryContentTableWidget</class>' '<class>mozc::gui::DictionaryContentTableWidget</class>'
          '';
      });
    })
  ];
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
