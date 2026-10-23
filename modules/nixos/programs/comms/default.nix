{ self, ... }:
{
  flake.nixosModules.applicationsComms = {
    imports = [
      self.nixosModules.applicationsCommsMisc
      self.nixosModules.applicationsCommsOptions
      self.nixosModules.applicationsCommsNixcord
    ];
  };
}
