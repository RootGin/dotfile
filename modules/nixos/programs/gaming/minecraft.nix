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
  options.my.programs.gaming.minecraft = {
    openFirewall = lib.mkEnableOption "Open Minecraft server LAN/WAN ports (25565 TCP, 19132 UDP)";
  };

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

    networking.firewall = lib.mkIf cfg.minecraft.openFirewall {
      allowedTCPPorts = [ 25565 ];
      allowedUDPPorts = [ 19132 ];
    };
  };
}
