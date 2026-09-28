{ self, ... }:
{
  flake.nixosModules.applicationsProductivityOptions =
    { lib, ... }:
    {
      options.programs.productivity = {
        enable = lib.mkEnableOption "Enable the productivity module";
      };
    };
}
