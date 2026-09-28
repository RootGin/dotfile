{ self, ... }:
{
  flake.nixosModules.applicationsProductivityPackages =
    { config, lib, pkgs, ... }:
    let
      username = config.userOptions.username;
    in
    {
      config = lib.mkIf config.programs.productivity.enable {
        environment.systemPackages = with pkgs; [
          kdePackages.kdenlive
          obsidian
        ];

        home-manager.users.${username}.programs = {
          onlyoffice.enable = true;
          zathura.enable = true;
        };
      };
    };
}