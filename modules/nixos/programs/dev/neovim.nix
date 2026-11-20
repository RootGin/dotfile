{
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [ inputs.nvf.nixosModules.default ];

  config = lib.mkIf config.my.programs.dev.enable {
    programs.nvf = {
      enable = true;
    };
  };
}
