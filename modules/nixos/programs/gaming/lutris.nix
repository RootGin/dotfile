{ self, ... }:
{
  flake.nixosModules.applicationsGamingLutris =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.gaming;
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
    };
}
