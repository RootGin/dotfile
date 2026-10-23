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
      username = config.userOptions.username;
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
