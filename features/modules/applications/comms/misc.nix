{ self, ... }:
{
  flake.nixosModules.applicationsCommsMisc = {
    config,
    lib,
    pkgs,
    ...
  }:
  let
    username = config.userOptions.username;
  in {
    config = lib.mkIf config.programs.comms.enable {
      home-manager.users.${username} = {
        home.packages = with pkgs; [
          element-desktop
          signal-desktop
          teamspeak6-client
          wasistlos
          zoom-us
          zulip
        ];
      };
    };
  };
}
