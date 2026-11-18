{ config, lib, ... }:
{
  # NetBird routing peer for the homelab; headless, so no UI.
  my.services.netbird.routingPeer = true;

  # Prevent lockout on headless server: allow password authentication if keys aren't provisioned
  services.openssh.settings.PasswordAuthentication = true;
}
