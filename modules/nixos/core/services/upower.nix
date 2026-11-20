{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.my.desktop.enable {
    services.upower.enable = true;
  };
}
