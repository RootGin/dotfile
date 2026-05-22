{ self, inputs, ... }:
{
  flake.nixosModules.modulesDesktopKde =
    { config, lib, pkgs, ... }:
    {
      config = {
        services.desktopManager.plasma6.enable = true;

        environment.plasma6.excludePackages = with pkgs.kdePackages; [
          plasma-browser-integration
          oxygen
        ];

        environment.systemPackages = with pkgs.kdePackages; [
          kate
          ark
        ];

        xdg.portal = {
          enable = true;
          extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
        };
      };
    };
}
