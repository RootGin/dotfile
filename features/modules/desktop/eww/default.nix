# Elkowar's Wacky Widgets (EWW)
#
# A standalone widget system written in Rust for creating custom widgets
# in any window manager.
#
# Config files:
#   eww.yuck  — widget layout (yuck DSL) → ~/.config/eww/eww.yuck
#   eww.scss  — widget styling            → ~/.config/eww/eww.scss
#
# Usage:
#   Launch the bar:   eww open bar
#   Close the bar:    eww close bar
#   Kill all widgets: eww kill
#   Reload config:    eww reload

{ self, inputs, ... }:
{
  flake.nixosModules.modulesDesktopEww =
    {
      config,
      pkgs,
      ...
    }:
    let
      username = config.userOptions.username;
    in
    {
      environment.systemPackages = with pkgs; [ eww ];

      home-manager.users.${username} = {
        xdg.configFile."eww/eww.yuck".source = ./eww.yuck;
        xdg.configFile."eww/eww.scss".source = ./eww.scss;
      };
    };
}
