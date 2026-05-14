{ self, ... }:
{
  flake.nixosModules.applicationsAiOptions =
    { lib, ... }:
    {
      options.programs.ai = {
        enable = lib.mkEnableOption "Enable AI tools";

        opencode = {
          enable = lib.mkEnableOption "Enable opencode agent";

          model = lib.mkOption {
            type = lib.types.str;
            default = "copilot.gpt-4o-mini";
            example = "copilot.gpt-4o-mini";
            description = "Default model for opencode to use. Uses GitHub Copilot (free with GitHub account).";
          };

          mcpServers = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = { };
            description = "Extra MCP servers to add to opencode config.";
          };
        };

        claude-code = {
          enable = lib.mkEnableOption "Enable Claude Code";

          providers.deepseek = {
            model = lib.mkOption {
              type = lib.types.str;
              default = "deepseek-v4-pro";
              description = "DeepSeek model for opus/sonnet tier.";
            };
            subagentModel = lib.mkOption {
              type = lib.types.str;
              default = "deepseek-v4-flash";
              description = "DeepSeek model for haiku/subagent tier.";
            };
          };

          providers.qwen = {
            model = lib.mkOption {
              type = lib.types.str;
              default = "qwen-max";
              description = "Qwen model for opus/sonnet tier.";
            };
            subagentModel = lib.mkOption {
              type = lib.types.str;
              default = "qwen-turbo";
              description = "Qwen model for haiku/subagent tier.";
            };
          };
        };

        gkg = {
          enable = lib.mkEnableOption "Enable GitLab Knowledge Graph (code graph server)";
        };
      };
    };
}
