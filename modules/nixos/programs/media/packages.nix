{ self, ... }:
{
  flake.nixosModules.applicationsMediaPackages =
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
      config = lib.mkIf config.my.programs.media.enable {
        home-manager.users.${username}.home.packages = with pkgs; [
          vlc
          bottles
          yt-dlp
          ffmpeg
          komikku
        ];
      };
    };
}
