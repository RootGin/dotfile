{ self, inputs, ... }:
{
  flake.nixosModules.modulesServicesNetbird =
    { config, lib, pkgs, ... }:
    {
      options.servicesModule.netbird = {
        enable = lib.mkEnableOption "Enable NetBird VPN";

        ui = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Expose the netbird-ui wrapper (needs a graphical session)";
        };

        routingPeer = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Serve NetBird network routes / exit nodes to other peers";
        };
      };

      config = lib.mkIf config.servicesModule.netbird.enable {
        services.netbird = {
          enable = true;
          ui.enable = config.servicesModule.netbird.ui;
        } // lib.optionalAttrs config.servicesModule.netbird.routingPeer {
          useRoutingFeatures = "client";
        };

        networking.firewall.trustedInterfaces = [ "wt0" ];
      };
    };
}