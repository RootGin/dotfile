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
  imports = [
    ./nixcord
  ];

  options.my.programs.comms = {
    enable = lib.mkEnableOption "Enables communication module";
  };

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
