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
        emulation = {
          waydroid.enable = false;
        };
        ai = {
          enable = true;
          opencode = {
            enable = true;
            ponytail.enable = true;
          };
          "agent-skills" = {
            enable = true;
            ui-ux-pro-max.enable = true;
            mattpocock = {
              enable = true;
              engineering = true;
              productivity = true;
            };
          };
        };
      };
    };
}
