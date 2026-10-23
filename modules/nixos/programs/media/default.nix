{ self, ... }:
{
  flake.nixosModules.applicationsMedia = {
    imports = [
      self.nixosModules.applicationsMediaOptions
      self.nixosModules.applicationsMediaSpicetify
      self.nixosModules.applicationsMediaPackages
    ];
  };
}
