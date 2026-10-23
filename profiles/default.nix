{ self, ... }:
{
  flake.nixosModules.profiles = {
    imports = [
      self.nixosModules.profileServer
      self.nixosModules.profileWorkstation
    ];
  };
}