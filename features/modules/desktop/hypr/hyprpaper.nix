{ self, inputs, ... }:
{
  flake.nixosModules.modulesDesktopHyprHyprpaper =
    {
      config,
      ...
    }:
    let
      username = config.userOptions.username;
      wallpaper = config.userOptions.wallpaper;
    in
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      home-manager.users.${username} = _: {
        stylix.targets.hyprpaper.enable = false;
        services.hyprpaper = {
          enable = true;
          settings = {
            preload = [ "/home/${username}/.config/backgrounds/${wallpaper}" ];
            splash = false;
            wallpaper = [
              {
                monitor = "";
                # hyprpaper does not expand `~`; use an absolute path.
                path = "/home/${username}/.config/backgrounds/${wallpaper}";
                fit_mode = "cover";
              }
            ];
          };
        };
      };
    };
}
