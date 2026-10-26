{ lib, ... }:
{
  options.my.programs.productivity = {
    enable = lib.mkEnableOption "Enable the productivity module";

    end-rs = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable end-rs eww notification daemon";
      };
    };
  };
}
