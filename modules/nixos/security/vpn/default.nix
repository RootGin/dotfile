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

  config = {
    services.zerotierone.enable = config.my.security.vpn.zerotier.enable;

    environment.systemPackages = lib.mkIf config.my.desktop.enable (
      with pkgs;
      [
        proton-vpn
        proton-vpn-cli
        networkmanager-openvpn
      ]
    );

    services.dbus.packages = lib.mkIf config.my.desktop.enable [ pkgs.networkmanager-openvpn ];
    networking.networkmanager.plugins = lib.mkIf config.my.desktop.enable [
      pkgs.networkmanager-openvpn
    ];
  };
}
