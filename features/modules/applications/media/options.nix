{ self, ... }:
{
  flake.nixosModules.applicationsMediaOptions =
    { lib, ... }:
    {
      options.programs.media = {
        enable = lib.mkEnableOption "Enables media module";
      };
    };
}
