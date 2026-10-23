{ self, inputs, ... }:
{
  flake.nixosConfigurations.thumb = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ../../modules/nixos
      ../common
      ../../profiles/server.nix
      ./modules/userOptions.nix
      ./modules/services.nix
      ./hardware-configuration.nix
    ];
  };
}
