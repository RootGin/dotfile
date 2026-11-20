{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.my.desktop.enable {
    security.rtkit.enable = true;
  };
}
