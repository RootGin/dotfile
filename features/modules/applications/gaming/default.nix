{ self, ... }:
{
  flake.nixosModules.applicationsGaming = {
    imports = [
      self.nixosModules.applicationsGamingOptions
      self.nixosModules.applicationsGamingBase
      self.nixosModules.applicationsGamingSteam
      self.nixosModules.applicationsGamingMinecraft
      self.nixosModules.applicationsGamingLutris
      self.nixosModules.applicationsGamingWine
      self.nixosModules.applicationsGamingRoblox
    ];
  };
}
