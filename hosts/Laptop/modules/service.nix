{ self, ... }:
{
  flake.nixosModules.hostLaptopModulesServices =
    { ... }:
    {
      config.services.softether.vpnclient.enable = true;
    };
}
