{ lib, ... }:
{
  config = {
    my.services.netbird.enable = true;

    # Headless power & display savings.
    # Display manager, bluetooth and pipewire follow my.desktop.enable (off by default).
    services.openssh.enable = true;
    my.security.hardening.enable = lib.mkDefault true;
  };
}
