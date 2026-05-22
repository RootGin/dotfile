{ self, ... }:
{
  flake.nixosModules.applicationsAiConfig =
    { config, lib, pkgs, ... }:
    let
      inherit (config.userOptions) username;
      cfg = config.programs.ai;
      ollamaCfg = cfg.ollama;
      opencodeCfg = cfg.opencode;
    in
    {
      options.programs.ai.ollama = {
        enable = lib.mkEnableOption "Enable Ollama";

        host = lib.mkOption {
          type = lib.types.str;
          default = "0.0.0.0";
        };

        port = lib.mkOption {
          type = lib.types.int;
          default = 11434;
        };

        models = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "qwen2.5-coder:7b"
          ];
        };
      };

      config = lib.mkIf (cfg.enable && ollamaCfg.enable) {
        services.ollama = {
          enable = true;
          package = pkgs.ollama-cpu;

          host = ollamaCfg.host;
          port = ollamaCfg.port;

          loadModels = ollamaCfg.models;
        };

        environment.systemPackages = with pkgs; [
          ollama-cpu
        ];

        home-manager.users.${username} = {
          xdg.configFile."opencode/providers.json" = {
            force = true;
            text = builtins.toJSON {
              providers = {
                ollama = {
                  type = "openai";
                  base_url = "http://${ollamaCfg.host}:${toString ollamaCfg.port}/v1";
                  api_key = "ollama";

                  models = {
                    default = "qwen2.5-coder:7b";
                    reasoning = "deepseek-r1:7b";
                    fast = "phi4";
                  };
                };
              };
            };
          };

          xdg.configFile."opencode/opencode.json" = {
            force = true;
            text = builtins.toJSON {
              autoupdate = false;

              provider = {
                default = "ollama";
              };

              model = "qwen2.5-coder:7b";

              small_model = "phi4";

              reasoning_model = "deepseek-r1:7b";

              base_url = "http://${ollamaCfg.host}:${toString ollamaCfg.port}/v1";

              context_window = 8192;

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
        };
      };
    };
}
