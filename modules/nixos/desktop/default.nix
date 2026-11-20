{ config, inputs, lib, ... }:
{
  imports = [
    inputs.luciole.nixosModules.default
    ./options.nix
    ./eww
    ./ly
    ./stylix
    ./xdg
    ./niri
  ];

  config = lib.mkIf config.my.desktop.enable {
    programs.luciole.enable = true;

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      WEBKIT_DISABLE_COMPOSITING_MODE = "1";
    };

    home-manager.users.${config.my.user.username}.dconf.settings."org/gnome/desktop/interface".color-scheme =
      "prefer-dark";
  };
}
