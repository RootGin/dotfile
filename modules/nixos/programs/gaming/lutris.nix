{
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.programs.gaming;
    in
    {
      config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          lutris
          winetricks
          wineWow64Packages.stable
        ];

        programs.steam.enable = lib.mkDefault true;
      };
    }
