{ self, inputs, ... }:
{
  flake.nixosModules.hostCommonModulesPrograms =
    { pkgs, ... }:
    {
      config.programs = {
        comms.enable = true;
        content.enable = true;
        dev.enable = true;
        emulation.enable = true;
        gaming.enable = true;
        media.enable = true;
        productivity.enable = true;
        terminal.enable = true;
        uni.enable = true;
      };
    };
}
