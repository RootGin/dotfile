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
      environment.systemPackages = [
        pkgs.proton-vpn
      ];

      services.zerotierone = {
        enable = true;
      };

      systemd.services.zerotierone = lib.mkIf config.security.agenix.enable {
        postStart = ''
          ${pkgs.zerotierone}/bin/zerotier-cli join "$(cat ${
            config.age.secrets."zerotier-network-id".path
          })" || true
        '';
      };

      networking.firewall.allowedTCPPorts = [ 25565 ];
      networking.firewall.allowedUDPPorts = [ 19132 ];
    };
}
