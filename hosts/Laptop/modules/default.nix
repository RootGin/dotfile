{ self, inputs, ... }:
{
  flake.nixosModules.hostLaptopModules = {
    imports = [
      self.nixosModules.hostLaptopModulesHardware
      self.nixosModules.hostLaptopModulesPrograms
      self.nixosModules.hostLaptopModulesServices
      self.nixosModules.hostLaptopModulesUserOptions
    ];
  };
}
