{ self, ... }:
{
  flake.nixosModules.applicationsProductivityPackages =
    { config, lib, pkgs, ... }:
    let
      username = config.userOptions.username;

      # Upstream ships a glibc binary only; no nixpkgs package.
      end-rs = pkgs.stdenvNoCC.mkDerivation {
        pname = "end-rs";
        version = "0.1.26";
        src = pkgs.fetchurl {
          url = "https://github.com/Dr-42/end-rs/releases/download/v0.1.26/end-rs";
          hash = "sha256-fRNc+5q1WbeVrZ6ai1uMMD/n+bQaE5QCE28mVJxJFAE=";
        };
        dontUnpack = true;
        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        autoPatchelfIgnoreMissingDeps = [ "libgcc_s.so.1" ];
        installPhase = "install -Dm755 $src $out/bin/end-rs";
      };
    in
    {
      config = lib.mkIf config.programs.productivity.enable {
        environment.systemPackages = with pkgs; [
          kdePackages.kdenlive
          obsidian
          end-rs
        ];

        home-manager.users.${username} = {
          programs = {
            onlyoffice.enable = true;
            zathura.enable = true;
          };

          systemd.user.services.end-rs = {
            Unit = {
              Description = "end-rs eww notification daemon";
              After = [ "graphical-session.target" ];
              PartOf = [ "graphical-session.target" ];
            };
            Service = {
              ExecStart = "${end-rs}/bin/end-rs daemon";
              Restart = "on-failure";
              RestartSec = 5;
            };
            Install.WantedBy = [ "default.target" ];
          };
        };
      };
    };
}