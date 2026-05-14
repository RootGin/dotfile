{ self, ... }:
{
  flake.nixosModules.applicationsAiConfig =
    { config, lib, pkgs, ... }:
    let
      inherit (config.userOptions) username;
      cfg = config.programs.ai;
      opencodeCfg = cfg.opencode;

      # GitLab Knowledge Graph pre-built binary
      gkg = pkgs.stdenv.mkDerivation {
        name = "gkg";
        src = pkgs.fetchurl {
          url = "https://gitlab.com/api/v4/projects/gitlab-org%2Frust%2Fknowledge-graph/releases/v0.25.0/downloads/gkg-linux-x86_64.tar.gz";
          hash = "sha256-VoMvw0jyeKK+I3QnqQeHMhD1BsoZpfsMGIO1547q8+A=";
        };
        sourceRoot = ".";
        installPhase = ''
          mkdir -p $out/bin
          cp gkg $out/bin/
          chmod +x $out/bin/gkg
        '';
      };
    in
    {
      config = lib.mkIf (cfg.enable && opencodeCfg.enable) {
        environment.systemPackages = with pkgs; [
          opencode
        ];

        home-manager.users.${username} = {
          home.packages = lib.optionals cfg.gkg.enable [ gkg ];

          xdg.configFile."opencode/opencode.json" = {
            force = true;
            text = builtins.toJSON {
              autoupdate = false;

              mcp = {
                context7 = {
                  type = "local";
                  enabled = true;
                  command = [
                    "npx"
                    "-y"
                    "@upstash/context7-mcp"
                  ];
                };
                deepwiki = {
                  type = "remote";
                  url = "https://mcp.deepwiki.com/mcp";
                };
                memory = {
                  type = "local";
                  enabled = true;
                  command = [
                    "npx"
                    "-y"
                    "@modelcontextprotocol/server-memory"
                  ];
                };
                "sequential-thinking" = {
                  type = "local";
                  enabled = true;
                  command = [
                    "npx"
                    "-y"
                    "@modelcontextprotocol/server-sequential-thinking"
                  ];
                };
                gitlab-knowledge-graph = {
                  type = "remote";
                  url = "http://localhost:27495/mcp";
                  headers = {
                    Accept = "application/json, text/event-stream";
                  };
                };
              }
              // opencodeCfg.mcpServers;

              plugin = [
                "opencode-pty"
                "octto"
                "opencode-worktree"
                "plannotator"
                "opencode-md-table-formatter"
                "oh-my-opencode"
              ];
            };
          };

          systemd.user.services.gkg = lib.mkIf cfg.gkg.enable {
            Unit = {
              Description = "GitLab Knowledge Graph server";
              After = [ "network.target" ];
            };
            Service = {
              Type = "simple";
              ExecStart = "${gkg}/bin/gkg server start";
              Restart = "on-failure";
              RestartSec = "5";
            };
            Install = {
              WantedBy = [ "default.target" ];
            };
          };
        };
      };
    };
}
