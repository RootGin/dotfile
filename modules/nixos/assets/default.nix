{
  inputs,
  config,
  lib,
  ...
}:
let
  username = config.my.user.username;
in
{
  config = lib.mkIf config.my.desktop.enable {
    home-manager.users.${username} = _: {
      home.file = {
        ".config/backgrounds".source = ./wallpapers;
        ".config/nixlogo.png".source = ./logo/nix-snowflake.png;
      };
    };
  };
}
