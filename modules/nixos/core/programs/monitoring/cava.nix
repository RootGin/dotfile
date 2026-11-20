{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = lib.optionals config.my.desktop.enable [ pkgs.cava ];
}
