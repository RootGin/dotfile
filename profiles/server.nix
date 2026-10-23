{ self, ... }:
{
  flake.nixosModules.profileServer =
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
        # mkForce: bluetooth/pipewire/ly are hardcoded to true in features/.
        services.xserver.enable = lib.mkForce false;
        services.displayManager.ly.enable = lib.mkForce false;
        hardware.bluetooth.enable = lib.mkForce false;
        services.pipewire.enable = lib.mkForce false;
      };
    };
}