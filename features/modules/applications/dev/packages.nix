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
        (python3.withPackages (ps: [ ps.pygobject3 ]))
        rustc
        cargo
      ];
    in
    {
      config = lib.mkIf config.programs.dev.enable {
        environment.systemPackages =
          defaultPackages ++ config.programs.dev.optionalPackages;
        # Default JDK for Maven builds (qlctkt-service = Java 17).
        environment.sessionVariables.JAVA_HOME = "${pkgs.jdk17}";
      };
    };
}
