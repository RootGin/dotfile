{ self, ... }:
{
  flake.nixosModules.applicationsProductivityDrawio =
    { config, lib, pkgs, ... }:
    {
      config = lib.mkIf config.programs.productivity.enable {
        environment.systemPackages = [ pkgs.drawio ];
      };
    };
}
