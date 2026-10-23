{ config, ... }:
{
  config.my.user = {
    hostName = "thumb";
    username = "rootgin";
    dots = "/etc/nixos";
    # Server fallbacks to satisfy options.nix
    browser = "zen-twilight";
    colorScheme = "nord";
    spicetifyColorScheme = "Nord";
    wallpaper = "nord.png";
  };
}
