{ self, ... }:
{
  flake.nixosModules.applicationsDevPackages =
    { config, lib, pkgs, ... }:
    let
      defaultPackages = with pkgs; [
        devenv
        gitui
        nodejs
        prettier
        nix-output-monitor
        jdk11
        jdk17
        maven
        gradle
        docker-compose
        (python3.withPackages (ps: [ ps.pygobject3 ps.pyyaml ]))
        rustc
        cargo
      ];
    in
    {
      config = lib.mkIf config.programs.dev.enable {
        environment.systemPackages =
          defaultPackages ++ config.programs.dev.optionalPackages;
        environment.sessionVariables.JAVA_HOME = "${pkgs.jdk17}";
      };
    };
}
