{ inputs, config, ... }:
let
  username = config.my.user.username;
in
{
  home-manager.users.${username} = _: {
    home.file = {
      ".config/backgrounds".source = ./wallpapers;
      ".config/nixlogo.png".source = ./logo/nix-snowflake.png;
    };
  };
}
