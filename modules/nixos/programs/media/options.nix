{ self, ... }:
{
  flake.nixosModules.applicationsMediaOptions =
    { lib, ... }:
    {
      options.my.programs.media = {
        enable = lib.mkEnableOption "Enables media module";
      };
    };
}
