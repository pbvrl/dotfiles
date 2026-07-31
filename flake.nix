{
  # inputs.nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  inputs.sops-nix.url = "github:mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.disko.url = "github:nix-community/disko/latest";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  inputs.lanzaboote.url = "github:nix-community/lanzaboote";
  inputs.lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {...} @ inputs: let
    privatePath = /home/nixos/.config/nixos/private/private.nix;
    privateImports = inputs.nixpkgs.lib.optional (builtins.pathExists privatePath) privatePath;
  in {
    nixosConfigurations = {
      base = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules =
          [
            {networking.hostName = "base";}
            ./hosts/config.nix
            ./hosts/basic_config.nix
            ./hosts/networking.nix
            inputs.sops-nix.nixosModules.sops
            inputs.disko.nixosModules.disko
            inputs.lanzaboote.nixosModules.lanzaboote
            ./hosts/base/disko.nix
            ./hosts/base/lanzaboote.nix
            ./hosts/base/hardware-configuration.nix
          ]
          ++ privateImports;
      };
      iso = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          {networking.hostName = "iso";}
          ./hosts/config.nix
          ./hosts/basic_config.nix
          ./hosts/networking.nix
          inputs.sops-nix.nixosModules.sops
          ./hosts/iso/iso.nix
        ];
      };
      thinkpad = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules =
          [
            {networking.hostName = "thinkpad";}
            ./hosts/config.nix
            ./hosts/basic_config.nix
            ./hosts/networking.nix
            inputs.sops-nix.nixosModules.sops
            inputs.disko.nixosModules.disko
            inputs.lanzaboote.nixosModules.lanzaboote
            ./hosts/thinkpad/intel.nix
            ./hosts/thinkpad/disko.nix
            ./hosts/thinkpad/lanzaboote.nix
            ./hosts/thinkpad/hardware-configuration.nix
          ]
          ++ privateImports;
      };
      lifebook = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules =
          [
            {networking.hostName = "lifebook";}
            ./hosts/config.nix
            ./hosts/basic_config.nix
            ./hosts/networking.nix
            inputs.sops-nix.nixosModules.sops
            ./hosts/lifebook/intel.nix
            ./hosts/bootlader.nix
            ./hosts/lifebook/hardware-configuration.nix
          ]
          ++ privateImports;
      };
      pc = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules =
          [
            {networking.hostName = "pc";}
            ./hosts/config.nix
            ./hosts/basic_config.nix
            ./hosts/networking.nix
            inputs.sops-nix.nixosModules.sops
            ./hosts/pc/nvidia.nix
            ./hosts/pc/amd.nix
            ./hosts/bootlader.nix
            ./hosts/pc/hardware-configuration.nix
          ]
          ++ privateImports;
      };
    };
  };
}
