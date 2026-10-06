{ self, inputs, ... }:
{
  flake.nixosModules.applicationsEmulatorsWaydroid =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.programs.emulation.waydroid = {
        enable = lib.mkEnableOption "Waydroid Android container";
      };

      config = lib.mkIf config.programs.emulation.waydroid.enable {
        virtualisation.waydroid.enable = true;
        virtualisation.waydroid.package = pkgs.waydroid-nftables;

        environment.systemPackages = with pkgs; [
          waydroid-helper
        ];
      };
    };
}
