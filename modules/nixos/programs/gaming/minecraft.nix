{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.gaming;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.prismlauncher.override {
        jdks = [ pkgs.jdk21 ];
      })
    ];

    environment.etc."prismlauncher/prismlauncher.cfg".text = ''
      [General]
      JavaPath=${pkgs.jdk21}/bin/java
      AutoUpdate=true
    '';

    networking.firewall.allowedTCPPorts = [ 25565 ];
    networking.firewall.allowedUDPPorts = [ 19132 ];
  };
}
