{
    config,
    lib,
    pkgs,
    ...
  }:
  let
    username = config.my.user.username;
  in {
    config = lib.mkIf config.my.programs.comms.enable {
      home-manager.users.${username} = {
        home.packages = with pkgs; [
          element-desktop
          signal-desktop
          teamspeak6-client
          karere
          zoom-us
          zulip
        ];
      };
    };
  }
