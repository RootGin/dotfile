{ self, inputs, ... }:
{

  flake.nixosModules.modulesServicesVicinae =
    {
      config,
      lib,
      ...
    }:
    let
      username = config.userOptions.username;
    in
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];

      options.servicesModule.vicinae = {
        enable = lib.mkEnableOption "Enable vicinae service";
      };

      config = lib.mkIf config.servicesModule.vicinae.enable {
        home-manager.users.${username} = {
          imports = [
            inputs.vicinae.homeManagerModules.default
          ];
          stylix.targets.vicinae.enable = true;

          services.vicinae = {
            enable = true;
            systemd = {
              enable = true;
              autoStart = true;
              environment = {
                USE_LAYER_SHELL = 1;
              };
            };
            settings = {
              favicon_service = "twenty";
              font.normal.normal = "Geist";
            };
          };
        };
      };
    };
}
