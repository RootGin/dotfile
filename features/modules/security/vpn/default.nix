{ self, inputs, ... }:
{
  flake.nixosModules.modulesSecurityVpn =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs;[
        proton-vpn
        proton-vpn-cli
        netbird-ui
        networkmanager-openvpn
      ];

      services.dbus.packages = [ pkgs.networkmanager-openvpn ];
      networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
      
      services.netbird.enable = true;

      services.zerotierone = {
        enable = true;
      };

      networking.firewall.allowedTCPPorts = [ 25565 ];
      networking.firewall.allowedUDPPorts = [ 19132 ];
    };
}
