{ config, lib, ... }:
{
  imports = [
    ./options.nix
    ./eww
    ./ly
    ./stylix
    ./xdg
    ./niri
  ];

  config = lib.mkIf config.my.desktop.enable {
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      WEBKIT_DISABLE_COMPOSITING_MODE = "1";
    };

    services.xserver = {
      xkb.layout = "us";
      xkb.variant = "";
    };
  };
}
