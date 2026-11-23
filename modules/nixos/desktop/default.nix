{ config, inputs, lib, ... }:
let
  colors = config.lib.stylix.colors.withHashtag;
in
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

    home-manager.users.${config.my.user.username} = {
      dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

      xdg.configFile."luciole/colors.toml".text = ''
        [colors]
        primary = "${colors.base03}"
        on_primary = "${colors.base05}"
        primary_container = "${colors.base0F}"
        on_primary_container = "${colors.base06}"
        secondary = "${colors.base0D}"
        on_secondary = "${colors.base00}"
        secondary_container = "${colors.base02}"
        on_secondary_container = "${colors.base05}"
        tertiary = "${colors.base07}"
        on_tertiary = "${colors.base00}"
        tertiary_container = "${colors.base02}"
        on_tertiary_container = "${colors.base07}"
        error = "${colors.base08}"
        on_error = "${colors.base06}"
        error_container = "${colors.base02}"
        on_error_container = "${colors.base08}"
        surface = "${colors.base00}"
        on_surface = "${colors.base05}"
        on_surface_variant = "${colors.base04}"
        surface_container_low = "${colors.base01}"
        surface_container = "${colors.base01}"
        surface_container_high = "${colors.base02}"
        surface_container_highest = "${colors.base03}"
        outline_variant = "${colors.base03}"
        shadow = "${colors.base00}"
        scrim = "#000000"
        hover = "${colors.base07}"
        on_hover = "${colors.base00}"
      '';
    };
  };
}
