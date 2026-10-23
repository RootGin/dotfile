{ lib, ... }:
{
  options.my.programs.productivity = {
    enable = lib.mkEnableOption "Enable the productivity module";
  };
}
