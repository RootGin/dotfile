{ self, inputs, ... }:
{
  flake.nixosModules.modulesServicesTailscale =
    { config, lib, pkgs, ... }:
    {
      options.servicesModule.tailscale = {
        enable = lib.mkEnableOption "Enable Tailscale VPN";
        autoConnect = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Automatically reconnect after reboot (uses persisted session)";
        };
        extraUpFlags = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Extra flags passed to `tailscale up`";
        };
      };

      config = lib.mkIf config.servicesModule.tailscale.enable {
        services.tailscale = {
          enable = true;
          autoConnect = config.servicesModule.tailscale.autoConnect;
          extraUpFlags = config.servicesModule.tailscale.extraUpFlags;
        };

        systemd.services.tailscale.stateDir = {
          enable = true;
          path = "/var/lib/tailscale";
        };

        networking.firewall.trustedInterfaces = [ "tailscale0" ];
      };
    };
}
