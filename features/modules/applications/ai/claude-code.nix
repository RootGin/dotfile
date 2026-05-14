{ self, inputs, ... }:
{
  flake.nixosModules.applicationsAiClaudeCode =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.userOptions) username;
      ccCfg = config.programs.ai.claude-code;
      deepseekModel = ccCfg.providers.deepseek.model;
      deepseekSubagent = ccCfg.providers.deepseek.subagentModel;
      qwenModel = ccCfg.providers.qwen.model;
      qwenSubagent = ccCfg.providers.qwen.subagentModel;
    in
    {
      config = lib.mkIf (config.programs.ai.enable && ccCfg.enable) {
        environment.systemPackages = with pkgs; [
          claude-code
        ];

        home-manager.users.${username} = {
          xdg.configFile."claude/settings.local.json" = {
            text = builtins.toJSON {
              env = {
                CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
              };
            };
          };

          xdg.configFile."claude.json" = {
            text = builtins.toJSON {
              hasCompletedOnboarding = true;
            };
          };

          programs.zsh.initExtra = ''
            claude-deepseek() {
              ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic" \
              ANTHROPIC_AUTH_TOKEN=$(cat /run/secrets/deepseek-api-key) \
              ANTHROPIC_MODEL="${deepseekModel}" \
              ANTHROPIC_DEFAULT_OPUS_MODEL="${deepseekModel}" \
              ANTHROPIC_DEFAULT_SONNET_MODEL="${deepseekModel}" \
              ANTHROPIC_DEFAULT_HAIKU_MODEL="${deepseekSubagent}" \
              CLAUDE_CODE_SUBAGENT_MODEL="${deepseekSubagent}" \
              CLAUDE_CODE_EFFORT_LEVEL="max" \
              claude "$@"
            }

            claude-qwen() {
              ANTHROPIC_BASE_URL="https://dashscope-intl.aliyuncs.com/apps/anthropic" \
              ANTHROPIC_AUTH_TOKEN=$(cat /run/secrets/qwen-api-key) \
              ANTHROPIC_MODEL="${qwenModel}" \
              ANTHROPIC_DEFAULT_OPUS_MODEL="${qwenModel}" \
              ANTHROPIC_DEFAULT_SONNET_MODEL="${qwenModel}" \
              ANTHROPIC_DEFAULT_HAIKU_MODEL="${qwenSubagent}" \
              CLAUDE_CODE_SUBAGENT_MODEL="${qwenSubagent}" \
              CLAUDE_CODE_EFFORT_LEVEL="max" \
              claude "$@"
            }
          '';
        };
      };
    };
}
