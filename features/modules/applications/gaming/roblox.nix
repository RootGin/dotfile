{ self, ... }:
{
  flake.nixosModules.applicationsGamingRoblox =
    { config, lib, ... }:
    {
      config = lib.mkIf config.programs.gaming.enable {
        services.flatpak.packages = [
          "org.vinegarhq.Sober"
        ];
      };
    };
}
