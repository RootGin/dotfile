{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.security.vpn.zerotier = {
    enable = lib.mkEnableOption "ZeroTier One mesh VPN service";
  };

  config = lib.mkIf config.my.desktop.enable {
    environment.systemPackages = with pkgs; [
      proton-vpn
      proton-vpn-cli
      networkmanager-openvpn
    ];

    services.dbus.packages = [ pkgs.networkmanager-openvpn ];
    networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];

    services.zerotierone.enable = config.my.security.vpn.zerotier.enable;
  };
}
