{
  config,
  lib,
  ...
}:
{
  imports = [
    ./just.nix
    ./localsend.nix
    ./rclone.nix
    ./ripgrep.nix
  ];

  config = lib.mkIf config.my.desktop.enable {
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
  };
}
