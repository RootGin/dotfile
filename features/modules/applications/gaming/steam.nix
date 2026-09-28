{ self, ... }:
{
  flake.nixosModules.applicationsGamingSteam =
    { config, lib, ... }:
    {
      config = lib.mkIf config.programs.gaming.enable {
        programs = {
          gamemode.enable = true;
          steam = {
            enable = true;
            gamescopeSession.enable = true;
            remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;
          };
          gamescope = {
            enable = true;
            capSysNice = true;
            args = [
              "--rt"
              "--expose-wayland"
            ];
          };
        };
      };
    };
}
