{ self, inputs, ... }:
{
  flake.nixosModules.hostLaptopModulesPrograms =
    { pkgs, ... }:
    {
      config.programs = {
        browsing = {
          chromium = {
            enable = true;
            package = pkgs.brave;
          };
          zen = {
            enable = true;
          };
        };
        ai = {
          enable = true;
          opencode = {
            enable = true;
          };
          ollama = true;
          gkg = {
            enable = true;
          };
          claude-code = {
            enable = true;
          };
          "agent-skills" = {
            enable = true;
            frontend-design.enable = true;
            ui-ux-pro-max.enable = true;
            "everything-claude-code" = {
              enable = true;
              java = true;
              javascript = true;
              dotnet = true;
              devops = true;
              frontend = true;
              general = true;
            };
            "ocx-skills" = {
              enable = true;
            };
          };
        };
      };
    };
}
