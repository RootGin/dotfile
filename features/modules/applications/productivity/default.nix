{ self, ... }:
{
  flake.nixosModules.applicationsProductivity = {
    imports = [
      self.nixosModules.applicationsProductivityOptions
      self.nixosModules.applicationsProductivityPackages
      self.nixosModules.applicationsProductivityDrawio
    ];
  };
}
