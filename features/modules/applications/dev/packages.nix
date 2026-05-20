{ self, ... }:
{
  flake.nixosModules.applicationsDevPackages =
    { config, lib, pkgs, ... }:
    let
      defaultPackages = with pkgs; [
        devenv
        gitui
        gitkraken
        nodejs_latest
        prettier
        nix-output-monitor
        jdk17
        maven
        gradle
        python3
        rustc
        cargo
      ];
    in
    {
      config = lib.mkIf config.programs.dev.enable {
        environment.systemPackages =
          defaultPackages ++ config.programs.dev.optionalPackages;
      };
    };
}
