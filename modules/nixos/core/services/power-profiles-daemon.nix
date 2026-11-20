{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.my.desktop.enable {
    services.power-profiles-daemon.enable = true;
  };
}
