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
    home-manager.users.${username} = {
      home.file = {
        ".config/electron-flags.conf".source = ./electron-flags.conf;
      };
    };
  };
}
