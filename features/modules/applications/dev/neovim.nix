{ self, inputs, ... }:
{
  flake.nixosModules.applicationsDevNeovim =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.nvf.nixosModules.default ]

      config = lib.mkIf config.programs.dev.enable {
        stylix.targets.nvf.enable = false;
        programs.nvf = {
          enable = true;
        };
      };
    };
}
