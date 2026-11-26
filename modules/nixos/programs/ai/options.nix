{ lib, ... }:
{
  options.my.programs.ai = {
    enable = lib.mkEnableOption "Enable AI tools";

    deepseek-harness = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable DeepSeek Harness (dsh)";
      };

      profile = lib.mkOption {
        type = lib.types.str;
        default = "web";
        description = "DeepSeek Harness profile to manage declaratively";
      };

      dshmarket = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Install dshmarket (community visual plugin marketplace) into the DeepSeek Harness profile";
        };
      };

      plugins = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Additional DeepSeek Harness plugin packages to install via dsh plugin add";
      };
    };

    rea = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable REA (Reverse Engineer Anything) CLI and MCP server";
      };

      dsh = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Register REA as an MCP server in DeepSeek Harness (~/.dsh/cordis.patch.yml)";
        };
      };
    };

    opencode = {
      enable = lib.mkEnableOption "Enable opencode agent";

      mcpServers = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        description = "Extra MCP servers to add to opencode config.";
      };
    };
  };
}
