{ self, ... }:
{
  flake.nixosModules.applicationsCommsOptions =
    { lib, ... }:
    {
      options.my.programs.comms = {
        enable = lib.mkEnableOption "Enables communication module";
      };
    };
}
