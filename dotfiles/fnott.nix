{pkgs, ...}: {
  nixpkgs.overlays = [
    (final: prev: {
      fnott = prev.fnott.overrideAttrs (old: {
        patches = (old.patches or []) ++ [./fnott-arrival-order.patch];
      });
    })
  ];

  environment.systemPackages = [pkgs.fnott];
}
