{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.gaming;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wineWow64Packages.stable
      winetricks
      protontricks
      vulkan-tools
      vulkan-loader
      dxvk
    ];
  };
}
