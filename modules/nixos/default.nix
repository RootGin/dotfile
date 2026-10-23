{ self, ... }:
{
  flake.nixosModules.features = {
    imports = [
      self.nixosModules.assets
      self.nixosModules.modules
      self.nixosModules.core
      self.nixosModules.usersRootgin
    ];
  };
}
