{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

  inputs.sops-nix.url = "github:mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.handy.url = "github:cjpais/handy";
  inputs.handy.inputs.nixpkgs.follows = "nixpkgs";

  inputs.private.url = "git+file:///home/nixos/.config/nixos/private";
  inputs.private.flake = false;

  outputs = {...} @ inputs: {
    specialArgs = {inherit inputs;};
    nixosConfigurations = {
      thinkpad = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          {networking.hostName = "thinkpad";}
          ./hosts/config.nix
          ./hosts/base_config.nix
          inputs.handy.nixosModules.default
          "${inputs.private}/private.nix"
          inputs.sops-nix.nixosModules.sops
          ./hosts/thinkpad/intel.nix
          ./hosts/thinkpad/hardware-configuration.nix
        ];
      };
      lifebook = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          {networking.hostName = "lifebook";}
          ./hosts/config.nix
          ./hosts/base_config.nix
          inputs.handy.nixosModules.default
          "${inputs.private}/private.nix"
          inputs.sops-nix.nixosModules.sops
          ./hosts/lifebook/intel.nix
          ./hosts/lifebook/hardware-configuration.nix
        ];
      };
      pc = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          {networking.hostName = "pc";}
          ./hosts/config.nix
          ./hosts/base_config.nix
          inputs.handy.nixosModules.default
          "${inputs.private}/private.nix"
          inputs.sops-nix.nixosModules.sops
          ./hosts/pc/nvidia.nix
          ./hosts/pc/amd.nix
          ./hosts/pc/hardware-configuration.nix
        ];
      };
    };
  };
}
