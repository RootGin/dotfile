{ self, inputs, ... }:
{
  flake.nixosModules.modulesServicesBlueman =
    {
      config,
      lib,
      ...
    }:
    {
      options.my.services.blueman = {
        enable = lib.mkEnableOption "Enable blueman service aka bluetooth";
      };

      config = lib.mkIf config.my.services.blueman.enable {
        services.blueman.enable = true;
      };
    };
}
