{ self, inputs, ... }:
{
  flake.nixosConfigurations.Laptop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.features

      self.nixosModules.hostCommon
      self.nixosModules.hostLaptopHardware
      self.nixosModules.hostLaptopModules
    ];
  };
}
