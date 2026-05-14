{ self, inputs, ... }:
{
  flake.nixosModules.applicationsTerminal =
    { config, lib, pkgs, ... }:
    let
      username = config.userOptions.username;
    in
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      options.programs.terminal = {
        enable = lib.mkEnableOption "Enable terminal module";
      };

      config = lib.mkIf config.programs.terminal.enable {
        home-manager.users.${username} = {
          programs.kitty = {
            enable = true;
            shellIntegration.enableZshIntegration = true;
            settings = {
              background_opacity = lib.mkForce "0.5";
              cursor_shape = "block";
              cursor_blink_interval = 0;
              confirm_os_window_close = 0;
            };
          };
        };
      };
    };
}
