{ self, inputs, ... }:
{
  flake.nixosModules.hostCommonModulesShell = {
    config.my.shell = {
      # Keep zsh installed so anything referencing /run/current-system/sw/bin/zsh keeps working.
      zsh.enable = true;
      fish.enable = true;
    };
  };
}
