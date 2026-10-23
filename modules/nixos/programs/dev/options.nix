{ self, ... }:
{
  flake.nixosModules.applicationsDevOptions =
    { lib, pkgs, ... }:
    {
      options.my.programs.dev = {
        enable = lib.mkEnableOption "Enable developer tools";

        optionalPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ pkgs.arduino-ide ];
          example = [
            pkgs.nodejs_latest
            pkgs.gitkraken
          ];
          description = "List of optional packages to install alongside the default ones.";
        };
      };
    };
}
