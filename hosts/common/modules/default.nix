{ self, inputs, ... }:
{
  flake.nixosModules.hostCommonModules = {
    imports = [
      self.nixosModules.hostCommonModulesSecurity
      self.nixosModules.hostCommonModulesShell
    ];
  };
}