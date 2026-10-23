{ lib, ... }:
{
  config = {
    my.programs = {
      comms.enable = false;
      content.enable = false;
      dev.enable = false;
      emulation.enable = false;
      gaming.enable = false;
      media.enable = false;
      productivity.enable = false;
      terminal.enable = false;
      uni.enable = false;
    };

    my.services = {
      blueman.enable = false;
      flatpak.enable = false;
      vicinae.enable = false;
      netbird.enable = true;
      netbird.ui = false;
    };

    # Headless power & display savings.
    # Display manager, bluetooth and pipewire follow my.desktop.enable (off by default).
  };
}
