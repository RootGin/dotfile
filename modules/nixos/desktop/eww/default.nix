# Elkowar's Wacky Widgets (EWW)
#
# Custom widget system used with draftpaper-eww widgets and Niri.
#
# Widget repository:
#   Currently located at ~/.config/eww/draftpaper-eww (standalone git repo)
#   Spawned by Niri keybindings (Mod+X, Mod+B, Mod+Escape).
#
# If imported into this dotfile repository in the future:
#   Can link via home-manager:
#     xdg.configFile."eww/draftpaper-eww".source = ./draftpaper-eww;

{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.my.desktop.enable {
    environment.systemPackages = with pkgs; [
      eww
    ];
  };
}
