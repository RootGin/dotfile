{ config, ... }:
{
  services.gnome.gnome-keyring.enable = config.my.desktop.enable;
}
