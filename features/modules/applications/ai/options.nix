{ self, ... }:
{
  flake.nixosModules.applicationsAiOptions =
    { lib, ... }:
    {
      options.programs.ai = {
        enable = lib.mkEnableOption "Enable AI tools";

        opencode = {
          enable = lib.mkEnableOption "Enable opencode agent";

          ponytail = {
            enable = lib.mkEnableOption "Enable Ponytail plugin for opencode (github:DietrichGebert/ponytail)";
          };

          mcpServers = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = { };
            description = "Extra MCP servers to add to opencode config.";
          };
        };
      };
    };
}
