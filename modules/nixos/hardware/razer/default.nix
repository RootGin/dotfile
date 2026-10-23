{
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.my.hardware.razer = {
        enable = lib.mkEnableOption "Enable razer module";
      };

      config = lib.mkIf config.my.hardware.razer.enable {
        hardware.openrazer.enable = true;
        environment.systemPackages = with pkgs; [
          openrazer-daemon
          polychromatic
        ];
      };
    }
