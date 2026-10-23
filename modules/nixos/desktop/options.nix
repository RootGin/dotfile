{ lib, ... }:
{
  options.my.desktop.enable = lib.mkEnableOption "the graphical desktop stack (display manager, audio, bluetooth)";
}
