{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  # Evaluate overlay locally so nixpkgs.overlays is not polluted globally
  nix4vscode = (inputs.nix4vscode.overlays.default pkgs pkgs).nix4vscode;
in
{
  config = lib.mkIf config.my.programs.dev.enable {
    environment.systemPackages = [
      pkgs.nil

      (pkgs.vscode-with-extensions.override {
        vscode = pkgs.vscode;
        vscodeExtensions =
          (with pkgs.vscode-extensions; [
            # ── Java ──────────────────────────────────────────────────────
            redhat.vscode-xml

            # ── Theme ─────────────────────────────────────────────────────
            arcticicestudio.nord-visual-studio-code

            # ── Live Server ───────────────────────────────────────────────
            ritwickdey.liveserver

            # ── Web / Frontend ────────────────────────────────────────────
            esbenp.prettier-vscode
            dbaeumer.vscode-eslint

            # ── Python ────────────────────────────────────────────────────
            ms-python.python
            ms-python.vscode-pylance

            # ── LaTeX ─────────────────────────────────────────────────────
            james-yu.latex-workshop

            # ── Rust ──────────────────────────────────────────────────────
            rust-lang.rust-analyzer

          ])
          ++ nix4vscode.forVscode [
                # Extension Pack for Java members, from the marketplace directly
                # (nixpkgs' redhat.java is not kept up to date)
                "redhat.java"
                "vscjava.vscode-java-debug"
                "vscjava.vscode-java-test"
                "vscjava.vscode-maven"
                "vscjava.vscode-gradle"
                "vscjava.vscode-java-dependency"

                "jnoortheen.nix-ide"
                "eww-yuck.yuck"

                # ── Spring Boot ───────────────────────────────────────────────
                "vmware.vscode-spring-boot"
                "vscjava.vscode-spring-boot-dashboard"
                "vscjava.vscode-spring-initializr"

                # ── microservices ────────────────────────────
                "eamodio.gitlens"
                "usernamehw.errorlens"
                "sonarsource.sonarlint-vscode"
                "ms-azuretools.vscode-docker"
                "redhat.vscode-yaml"
                "humao.rest-client"
                "shengchen.vscode-checkstyle"
                "Oracle.sql-developer"

                # ── CI/CD & Kubernetes ───────────────────────
                "jmmeessen.jenkins-declarative-support"
                "ms-kubernetes-tools.vscode-kubernetes-tools"
              ];
      })
    ];
  };
}
