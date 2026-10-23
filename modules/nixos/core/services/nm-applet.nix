{ config, lib, ... }:
let
  username = config.my.user.username;
in
{
  config = lib.mkIf config.my.desktop.enable {
    home-manager.users.${username} = _: {
      services.network-manager-applet.enable = true;
    };
  };
}
