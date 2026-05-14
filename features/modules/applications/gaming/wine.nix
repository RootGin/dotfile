{ self, ... }:
{
  flake.nixosModules.applicationsGamingWine =
    { config, lib, pkgs, ... }:
    let
      cfg = config.programs.gaming;
    in
    {
      config = lib.mkIf cfg.enable {
        environment.systemPackages = with pkgs; [
          wineWowPackages.stable
          wine-staging
          winetricks
          protontricks
          vulkan-tools
          vulkan-loader
          dxvk
        ];
      };
    };
}
