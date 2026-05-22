# ai.nix — merged Ollama + opencode configuration
# Replaces: ollama.nix + opencode.nix (both wrote to opencode.json, causing clobber)
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

      # Model definitions — tuned for 16GB RAM, CPU-only
      # - qwen2.5-coder:7b  ~4.5GB  best pure coding 7B (default + fast)
      # - qwen3:8b          ~5.5GB  beats qwen2.5-14B on coding; has thinking mode (reasoning)
      # phi4 dropped — 14B is too heavy on CPU-only 16GB once OS + context load in
      defaultModel   = "qwen2.5-coder:7b";
      reasoningModel = "qwen3:8b";
      fastModel      = "qwen2.5-coder:7b";

      ollamaBaseUrl = "http://${ollamaCfg.host}:${toString ollamaCfg.port}/v1";
    in
    {
      # ── Ollama options ──────────────────────────────────────────────────────
      options.programs.ai.ollama = {
        enable = lib.mkEnableOption "Enable Ollama";

        host = lib.mkOption {
          type    = lib.types.str;
          default = "0.0.0.0";
        };

        port = lib.mkOption {
          type    = lib.types.int;
          default = 11434;
        };

        models = lib.mkOption {
          type    = lib.types.listOf lib.types.str;
          default = [ defaultModel reasoningModel ];
        };
      };

      # ── System + home-manager config ────────────────────────────────────────
      config = lib.mkIf cfg.enable {

        # Ollama service (only when ollama sub-option is enabled)
        services.ollama = lib.mkIf ollamaCfg.enable {
          enable  = true;
          package = pkgs.ollama-cpu;
          host    = ollamaCfg.host;
          port    = ollamaCfg.port;
          loadModels = ollamaCfg.models;
        };

        environment.systemPackages = with pkgs;
          lib.optionals ollamaCfg.enable [ ollama-cpu ]
          ++ lib.optionals opencodeCfg.enable [ opencode ];

        home-manager.users.${username} = lib.mkIf opencodeCfg.enable {

          # GKG binary
          home.packages = lib.optionals cfg.gkg.enable [ gkg ];

          # ── Single opencode.json (merged provider + MCP + plugins) ──────────
          xdg.configFile."opencode/opencode.json" = {
            force = true;
            text  = builtins.toJSON {
              autoupdate = false;

              # Provider: Ollama via OpenAI-compatible endpoint
              provider.default = lib.mkIf ollamaCfg.enable "ollama";

              model          = defaultModel;
              small_model    = fastModel;
              reasoning_model = reasoningModel;

              # Only set base_url when Ollama is enabled; otherwise opencode
              # will use its own default (cloud) provider config.
              base_url       = lib.mkIf ollamaCfg.enable ollamaBaseUrl;
              context_window = 8192;

              mcp =
                {
                  # ── Local MCP servers (CPU-safe, no internet required) ──────
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

                  # ── Remote MCP servers (require internet) ───────────────────
                  context7 = {
                    type    = "local";
                    enabled = true;
                    command = [ "npx" "-y" "@upstash/context7-mcp" ];
                  };

                  deepwiki = {
                    type = "remote";
                    url  = "https://mcp.deepwiki.com/mcp";
                  };

                  # ── GitLab Knowledge Graph (local service on :27495) ────────
                  gitlab-knowledge-graph = lib.mkIf cfg.gkg.enable {
                    type = "remote";
                    url  = "http://localhost:27495/mcp";
                    headers.Accept = "application/json, text/event-stream";
                  };
                }
                # Allow per-host extra MCP servers from opencode options
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

          # ── GKG systemd user service ────────────────────────────────────────
          systemd.user.services.gkg = lib.mkIf cfg.gkg.enable {
            Unit = {
              Description = "GitLab Knowledge Graph server";
              After       = [ "network.target" ];
            };
            Service = {
              Type       = "simple";
              # Explicit port so it matches the MCP url above
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
