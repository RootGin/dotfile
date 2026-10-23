{ inputs, config, ... }:
let
  username = config.my.user.username;
in
{
  home-manager.users.${username} = {
    home.file = {
      ".config/electron-flags.conf".source = ./electron-flags.conf;
    };
  };
}
