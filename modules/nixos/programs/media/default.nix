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
    ./spicetify.nix
  ];

  options.my.programs.media = {
    enable = lib.mkEnableOption "Enables media module";
  };

  config = lib.mkIf config.my.programs.media.enable {
    home-manager.users.${username}.home.packages = with pkgs; [
      mpv
      bottles
      yt-dlp
      ffmpeg
      komikku
    ];
  };
}
