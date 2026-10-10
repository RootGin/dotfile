{ self, ... }:
{
  flake.nixosModules.hostThumbModulesServices =
    { config, ... }:
    {
      # NetBird routing peer for the homelab; headless, so no UI.
      config.servicesModule.netbird = {
        enable = true;
        routingPeer = true;
        ui = false;
      };

      # SSH port already set globally in features/system/services/ssh.nix.
    };
}