{ self, ... }:
{
  flake.nixosModules.applicationsGamingMinecraft =
    { config, lib, pkgs, ... }:
    let
      cfg = config.programs.gaming; 
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
      };
    };
}
