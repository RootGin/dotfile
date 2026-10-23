{ config, ... }:
{
  config.my.user = {
    hostName = "thumb";
    username = "rootgin";
    dots = "/etc/nixos";
    # Server fallbacks to satisfy options.nix
    colorScheme = "nord";
    spicetifyColorScheme = "Nord";
  };
}
