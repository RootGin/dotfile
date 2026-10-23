{ config, lib, pkgs, ... }:
    {
      config = lib.mkIf config.my.programs.productivity.enable {
        environment.systemPackages = [ pkgs.drawio ];
      };
    }
