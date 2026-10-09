{ self, ... }:
{
  flake.nixosModules.profileWorkstation = {
    config.programs = {
      comms.enable = true;
      content.enable = true;
      dev.enable = true;
      emulation.enable = false;
      gaming.enable = true;
      media.enable = true;
      productivity.enable = true;
      terminal.enable = true;
      uni.enable = true;
    };

    config.servicesModule = {
      blueman.enable = true;
      flatpak.enable = true;
      vicinae.enable = true;
      netbird.enable = true;
      netbird.ui = true;
    };
  };
}