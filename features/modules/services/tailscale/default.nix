{ self, inputs, ... }:
{
  flake.nixosModules.modulesServicesTailscale =
    { config, lib, pkgs, ... }:
    {
      options.servicesModule.tailscale = {
        enable = lib.mkEnableOption "Enable Tailscale VPN";
        extraUpFlags = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Extra flags passed to `tailscale up`";
        };
      };

      config = lib.mkIf config.servicesModule.tailscale.enable {
        environment.systemPackages = [ pkgs.tailscale ];

        services.tailscale = {
          enable = true;
          extraUpFlags = config.servicesModule.tailscale.extraUpFlags;
        };

        networking.firewall.trustedInterfaces = [ "tailscale0" ];
      };
    };
}
