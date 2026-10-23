{ lib, ... }:
    {
      options.my.programs.comms = {
        enable = lib.mkEnableOption "Enables communication module";
      };
    }
