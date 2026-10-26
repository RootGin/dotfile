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
let
  username = config.my.user.username;
in
{
  config = lib.mkIf config.my.desktop.enable {
    environment.systemPackages = with pkgs; [
      eww
      python3
    ];

    home-manager.users.${username} = {
      # draftpaper-eww is currently maintained in ~/.config/eww/draftpaper-eww
      # xdg.configFile."eww/draftpaper-eww".source = ./draftpaper-eww;
    };
  };
}
