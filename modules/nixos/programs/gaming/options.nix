{ self, ... }:
{
  flake.nixosModules.applicationsGamingOptions =
    { lib, pkgs, ... }:
    {
      options.programs.gaming = {
        enable = lib.mkEnableOption "Complete gaming profile";

        extraPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "Additional gaming packages";
        };

        gamemode.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable gamemode performance optimizations";
        };
      };  
    };
}
