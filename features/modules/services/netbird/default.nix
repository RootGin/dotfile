{ self, inputs, ... }:
{
  flake.nixosModules.modulesServicesNetbird =
    { config, lib, pkgs, ... }:
    {
      options.servicesModule.netbird = {
        enable = lib.mkEnableOption "Enable NetBird VPN";
      };

      config = lib.mkIf config.servicesModule.netbird.enable {
        services.netbird = {
          enable = true;
          ui.enable = true;
        };

        networking.firewall.trustedInterfaces = [ "wt0" ];
      };
    };
}
