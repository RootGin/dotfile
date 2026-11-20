{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.my.desktop.enable {
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
  };
}
