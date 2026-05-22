# ai.nix — merged Ollama + opencode configuration
{ self, ... }:
{
  flake.nixosModules.applicationsAiConfig =
    { config, lib, pkgs, ... }:
    let
      inherit (config.userOptions) username;
      cfg = config.programs.ai;
      ollamaCfg = cfg.ollama;
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

      ollamaBaseUrl = "http://${ollamaCfg.host}:${toString ollamaCfg.port}/v1";

      # Models must be in "provider/model" format per opencode schema
      defaultModel   = "ollama/qwen2.5-coder:7b";
      reasoningModel = "ollama/qwen3:8b";
      fastModel      = "ollama/qwen2.5-coder:7b";

      gkgMcp = if cfg.gkg.enable then {
        gitlab-knowledge-graph = {
          type    = "remote";
          url     = "http://localhost:27495/mcp";
          headers = { Accept = "application/json, text/event-stream"; };
        };
      } else {};

      # provider block: only emitted when ollama is enabled
      ollamaProvider = if ollamaCfg.enable then {
        provider = {
          ollama = {
            # npm package opencode uses to talk to OpenAI-compatible endpoints
            npm = "openai";
            options = {
              apiKey  = "ollama";
              baseURL = ollamaBaseUrl;
            };
            # Declare the two models so opencode knows their capabilities
            models = {
              "qwen2.5-coder:7b" = {
                id          = "qwen2.5-coder:7b";
                name        = "Qwen2.5 Coder 7B";
                tool_call   = true;
                temperature = true;
                limit       = { context = 32768; output = 8192; };
              };
              "qwen3:8b" = {
                id          = "qwen3:8b";
                name        = "Qwen3 8B";
                reasoning   = true;
                tool_call   = true;
                temperature = true;
                limit       = { context = 32768; output = 8192; };
              };
            };
          };
        };
      } else {};

      opencodeJson = ollamaProvider // {
        "$schema"   = "https://opencode.ai/config.json";
        autoupdate  = false;
        model       = defaultModel;
        small_model = fastModel;

        # qwen3:8b handles reasoning — wire it in via the build agent
        agent = {
          build = {
            model = reasoningModel;
          };
        };

        mcp = {
          memory = {
            type    = "local";
            enabled = true;
            command = [ "npx" "-y" "@modelcontextprotocol/server-memory" ];
          };
          "sequential-thinking" = {
            type    = "local";
            enabled = true;
            command = [ "npx" "-y" "@modelcontextprotocol/server-sequential-thinking" ];
          };
          context7 = {
            type    = "local";
            enabled = true;
            command = [ "npx" "-y" "@upstash/context7-mcp" ];
          };
          deepwiki = {
            type = "remote";
            url  = "https://mcp.deepwiki.com/mcp";
          };
        } // gkgMcp // opencodeCfg.mcpServers;

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
      options.programs.ai.ollama = {
        enable = lib.mkEnableOption "Enable Ollama";

        host = lib.mkOption {
          type    = lib.types.str;
          default = "127.0.0.1";
        };

        port = lib.mkOption {
          type    = lib.types.int;
          default = 11434;
        };

        models = lib.mkOption {
          type    = lib.types.listOf lib.types.str;
          default = [ "qwen2.5-coder:7b" "qwen3:8b" ];
        };
      };

      config = lib.mkIf cfg.enable {

        services.ollama = lib.mkIf ollamaCfg.enable {
          enable     = true;
          package    = pkgs.ollama-cpu;
          host       = ollamaCfg.host;
          port       = ollamaCfg.port;
          loadModels = ollamaCfg.models;
        };

        environment.systemPackages =
          lib.optionals ollamaCfg.enable  (with pkgs; [ ollama-cpu ])
          ++ lib.optionals opencodeCfg.enable (with pkgs; [ opencode ]);

        home-manager.users.${username} = lib.mkIf opencodeCfg.enable {

          home.packages = lib.optionals cfg.gkg.enable [ gkg ];

          xdg.configFile."opencode/opencode.json" = {
            force = true;
            text  = builtins.toJSON opencodeJson;
          };

          systemd.user.services.gkg = lib.mkIf cfg.gkg.enable {
            Unit = {
              Description = "GitLab Knowledge Graph server";
              After       = [ "network.target" ];
            };
            Service = {
              Type       = "simple";
              ExecStart  = "${gkg}/bin/gkg server start --port 27495";
              Restart    = "on-failure";
              RestartSec = "5";
            };
            Install.WantedBy = [ "default.target" ];
          };
        };
      };
    };
}
