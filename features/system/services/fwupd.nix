{ self, inputs, ... }:
{
  flake.nixosModules.coreServicesFwupd = {
    services.fwupd.enable = true;
  };
}
