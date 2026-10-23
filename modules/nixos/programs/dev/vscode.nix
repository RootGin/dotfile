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
              ++ pkgs.nix4vscode.forVscodeExt (
                {
                  # vscode-java-debug mkdirs ".noConfigDebugAdapterEndpoints" inside
                  # extensionPath at activation; the nix store is read-only so
                  # activation throws and every java.debug.* command goes missing.
                  "vscjava.vscode-java-debug" = {
                    postPatch = ''
                      substituteInPlace dist/extension.js \
                        --replace-fail \
                          ',v=o.join(t,".noConfigDebugAdapterEndpoints")' \
                          ',v=o.join(require("os").tmpdir(),"vscode-java-debug")'
                    '';
                  };
                }
              ) [
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
              ];
          })
        ];
      };
    };
}
