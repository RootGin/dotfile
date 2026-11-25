{ config, ... }:
{
  services.displayManager.ly = {
    enable = config.my.desktop.enable;
    settings = {
      bigclock = "en";
      save = true;
      vi_mode = true;
    };
  };
}
