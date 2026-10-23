{ config, ... }:
    let
      username = config.my.user.username;
    in
    {
      home-manager.users.${username} = _: {
        services.network-manager-applet.enable = true;
      };
    }
