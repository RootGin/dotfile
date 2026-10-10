{ self, inputs, ... }:
{
  flake.nixosConfigurations.thumb = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.features

      self.nixosModules.hostCommon
      self.nixosModules.profileServer

      self.nixosModules.hostThumbModulesUserOptions
      self.nixosModules.hostThumbModulesServices
      self.nixosModules.hostThumbHardware
    ];
  };
}