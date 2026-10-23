{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.services.netbird = {
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

  config = lib.mkIf config.my.services.netbird.enable {
    services.netbird = {
      enable = true;
      ui.enable = config.my.services.netbird.ui;
    }
    // lib.optionalAttrs config.my.services.netbird.routingPeer {
      useRoutingFeatures = "client";
    };

    networking.firewall.trustedInterfaces = [ "wt0" ];
  };
}
