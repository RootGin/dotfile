{ config, lib, ... }:
{
  config = lib.mkIf config.my.programs.gaming.enable {
    services.flatpak.packages = [
      "org.vinegarhq.Sober"
      "org.vinegarhq.Vinegar"
    ];
  };
}
