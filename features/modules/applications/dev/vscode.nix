{ self, inputs, ... }:
{
  flake.nixosModules.applicationsDevVscode =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf config.programs.dev.enable {
        nixpkgs.overlays = [ inputs.nix4vscode.overlays.default ];

        environment.systemPackages = [
          pkgs.nil
          pkgs.nixfmt

          (pkgs.vscode-with-extensions.override {
            vscode = pkgs.vscodium;
            vscodeExtensions =
              (with pkgs.vscode-extensions; [
                # ── Java ──────────────────────────────────────────────────────
                redhat.vscode-xml
                redhat.java
                vscjava.vscode-java-debug
                vscjava.vscode-java-test
                vscjava.vscode-maven
                vscjava.vscode-java-dependency
                vscjava.vscode-gradle

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
              ++ pkgs.nix4vscode.forVscode [
                "jnoortheen.nix-ide"
                "eww-yuck.yuck"

                # ── Spring Boot ───────────────────────────────────────────────
                "vmware.vscode-spring-boot"
                "vscjava.vscode-spring-boot-dashboard"
                "vscjava.vscode-spring-initializr"
              ];
          })
        ];
      };
    };
}
