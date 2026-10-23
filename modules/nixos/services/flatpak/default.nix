{ self, inputs, ... }:
{
  flake.nixosModules.modulesServicesFlatpak =
    { config, lib, ... }:
    {
      imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

      options.servicesModule.flatpak = {
        enable = lib.mkEnableOption "Enable flatpak service";
      };

      config = lib.mkIf config.servicesModule.flatpak.enable {
        services.flatpak = {
          enable = true;
          update.onActivation = true;
        };
      };
    };
}
