{ self, ... }:
{
  flake.nixosModules.applicationsAiConfig =
    {
      config,
      lib,
      pkgs,
      ...
    }:
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

      gkgMcp =
        if cfg.gkg.enable then
          {
            gitlab-knowledge-graph = {
              type = "remote";
              url = "http://localhost:27495/mcp";
              headers = {
                Accept = "application/json, text/event-stream";
              };
            };
          }
        else
          { };

      opencodeJson = {
        "$schema" = "https://opencode.ai/config.json";
        autoupdate = false;

        mcp = {
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
          mcp-nixos = {
            type = "local";
            enabled = true;
            command = [ "${pkgs.mcp-nixos}/bin/mcp-nixos" ];
          };
        }
        // gkgMcp
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

    in
    {
      config = lib.mkIf cfg.enable {

        environment.systemPackages = lib.optionals opencodeCfg.enable (with pkgs; [ opencode mcp-nixos ]);

        home-manager.users.${username} = lib.mkIf opencodeCfg.enable {

          home.packages = lib.optionals cfg.gkg.enable [ gkg ];

          xdg.configFile."opencode/opencode.json" = {
            force = true;
            text = builtins.toJSON opencodeJson;
          };

          systemd.user.services.gkg = lib.mkIf cfg.gkg.enable {
            Unit = {
              Description = "GitLab Knowledge Graph MCP server";
              After = [ "network-online.target" ];
            };
            Service = {
              Type = "simple";
              ExecStart = "${gkg}/bin/gkg --repository-mode=hybrid --mcp-mode=sse /home/${username}/.local/share/gkg";
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
