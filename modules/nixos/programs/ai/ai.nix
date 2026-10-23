{ self, inputs, ... }:
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

      opencodeJson = {
        "$schema" = "https://opencode.ai/config.json";
        autoupdate = false;

        mcp = {
          deepwiki = {
            type = "remote";
            url = "https://mcp.deepwiki.com/mcp";
          };
          mcp-nixos = {
            type = "local";
            enabled = true;
            command = [ "${pkgs.mcp-nixos}/bin/mcp-nixos" ];
          };
          playwright = {
            type = "local";
            enabled = true;
            command = [
              "npx"
              "-y"
              "@playwright/mcp@latest"
            ];
          };
        }
        // opencodeCfg.mcpServers;

        plugin = [
          "opencode-pty"
          "opencode-worktree"
          "opencode-md-table-formatter"
        ]
        ++ lib.optionals opencodeCfg.ponytail.enable [
          "${inputs.ponytail}/.opencode/plugins/ponytail.mjs"
        ];
      };

    in
    {
      config = lib.mkIf cfg.enable {
        environment.systemPackages = (with pkgs; [ antigravity-cli antigravity-hub antigravity-ide]) ++ lib.optionals opencodeCfg.enable (with pkgs; [ opencode mcp-nixos ]);
        home-manager.users.${username} = lib.mkIf opencodeCfg.enable {
          xdg.configFile."opencode/opencode.json" = {
            force = true;
            text = builtins.toJSON opencodeJson;
          };
        };
      };
    };
}
