{ config, ... }:
{
  services.displayManager.ly = {
    enable = config.my.desktop.enable;
    settings = {
      bigclock = "en";
      save = true;
      setup_cmd = "";
      vi_mode = true;
    };
  };
}
