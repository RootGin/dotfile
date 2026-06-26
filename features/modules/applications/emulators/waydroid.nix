{ self, inputs, ... }:
{
  flake.nixosModules.applicationsEmulatorsWaydroid =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      username = config.userOptions.username;
    in
    {
      options.programs.emulation.waydroid = {
        enable = lib.mkEnableOption "Waydroid Android container";
      };

      config = lib.mkIf config.programs.emulation.waydroid.enable {
        virtualisation.waydroid.enable = true;

        environment.systemPackages = with pkgs; [
          waydroid-helper
        ];
      };
    };
}
