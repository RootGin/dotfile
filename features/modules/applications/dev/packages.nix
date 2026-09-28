{ self, ... }:
{
  flake.nixosModules.applicationsDevPackages =
    { config, lib, pkgs, ... }:
    let
      defaultPackages = with pkgs; [
        devenv
        gitui
        gitkraken
        nodejs
        prettier
        nix-output-monitor
        # ── qlctkt (Viettel) ────────────────────────────────────
        # templ_be/qlctkt-service targets Java 17; legacy libs
        # (templ_be/commons, security-common) target Java 11 with an old
        # Lombok that breaks on newer JDKs. Default JAVA_HOME to jdk17
        # (main service); build legacy libs with per-command override:
        #   JAVA_HOME=${pkgs.jdk11} mvn install -DskipTests
        # Sibling/private artifacts are pre-seeded in ~/.m2 (see notes).
        jdk11
        jdk17
        maven
        gradle
        # Local infra (Eureka/Config/Kafka/Redis/Hazelcast) runs via
        # docker-compose when the daemon is enabled.
        docker-compose
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
