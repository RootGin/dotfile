{ self, ... }:
{
  flake.nixosModules.applicationsCommsOptions =
    { lib, ... }:
    {
      options.programs.comms = {
        enable = lib.mkEnableOption "Enables communication module";
      };
    };
}
