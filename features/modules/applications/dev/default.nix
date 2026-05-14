{ self, ... }:
{
  flake.nixosModules.applicationsDev = {
    imports = [
      self.nixosModules.applicationsDevOptions
      self.nixosModules.applicationsDevPackages
      self.nixosModules.applicationsDevVscode
      self.nixosModules.applicationsDevNeovim
    ];
  };
}
