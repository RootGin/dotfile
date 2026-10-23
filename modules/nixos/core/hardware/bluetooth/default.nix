{ config, ... }:
{
  hardware.bluetooth = {
    enable = config.my.desktop.enable;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };
}
