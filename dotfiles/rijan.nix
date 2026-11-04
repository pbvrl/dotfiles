{
  nixpkgs.overlays = [
    (final: prev: let
      zig = final.zig_0_15;
      wm = final.stdenv.mkDerivation (finalAttrs: {
        pname = "rijan";
        version = "0-unstable-2026-04-26";
        src = final.fetchFromCodeberg {
          owner = "ifreund";
          repo = "rijan";
          rev = "e4d390e446d4da87de98a6c235ef59c7a0905058";
          hash = "sha256-8ETIIgr3Ze27hSc6FF/oXO5M0eVlbP9kxrjx0t5qHBw=";
        };
        zigDeps = zig.fetchDeps {
          inherit (finalAttrs) src pname version;
          hash = "sha256-Q3cSNZJEO/XxPp4fpEp1a9If9rQuK8owBl+32oBQ3YI=";
        };
        patches = [./rijan/system-libs.patch];
        postPatch = ''
          cp ${./rijan/rijan.janet} rijan.janet
          cp ${./rijan/init.janet} init.janet
          substituteInPlace build.zig \
            --replace-fail @wayland_xml@ ${final.wayland-scanner}/share/wayland/wayland.xml \
            --replace-fail @wayland_protocols@ ${final.wayland-protocols}/share/wayland-protocols
        '';
        postConfigure = ''
          ln -s ${finalAttrs.zigDeps} "$ZIG_GLOBAL_CACHE_DIR/p"
        '';
        nativeBuildInputs = [zig final.pkg-config final.wayland-scanner];
        buildInputs = [final.wayland final.wayland-protocols final.libxkbcommon];
      });
      init = final.writeShellScript "rijan-init" ''
        dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
        ${wm}/bin/rijan --autostart
        while true; do
          sleep 1
          ${wm}/bin/rijan
        done
      '';
      launcher = final.writeShellScriptBin "river-rijan" ''
        exec ${final.river}/bin/river -c ${init}
      '';
    in {
      rijan = final.symlinkJoin {
        name = "rijan";
        paths = [
          wm
          launcher
          (final.writeTextDir "share/wayland-sessions/river-rijan.desktop" ''
            [Desktop Entry]
            Name=River (rijan)
            Comment=River 0.5 with the rijan window manager
            Exec=${launcher}/bin/river-rijan
            Type=Application
          '')
        ];
        passthru.providedSessions = ["river-rijan"];
      };
    })
  ];
}
