{ self, inputs, ... }:
{
  flake.nixosConfigurations.Laptop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ../../modules/nixos
      ../common
      ../../profiles/workstation.nix
      ./hardware-configuration.nix
      ./modules
    ];
  };
}
