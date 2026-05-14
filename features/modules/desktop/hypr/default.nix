{ self, inputs, ... }:
{
  flake.nixosModules.modulesDesktopHypr =
    {
      config,
      pkgs,
      ...
    }:
    let
      username = config.userOptions.username;
    in
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager

        self.nixosModules.modulesDesktopHyprHypridle
        self.nixosModules.modulesDesktopHyprHyprland
        self.nixosModules.modulesDesktopHyprHyprlock
        self.nixosModules.modulesDesktopHyprHyprpanel
        self.nixosModules.modulesDesktopHyprHyprpaper
      ];

      environment = {
        systemPackages = with pkgs; [
          brightnessctl
          kdePackages.dolphin
          gthumb
          hyprpaper
          hyprshot
          kdePackages.kio-extras
          libnotify
          networkmanagerapplet
          pavucontrol
          playerctl
          pywal
          wl-clipboard
          yazi
          zenity
        ];
      };

      home-manager.users.${username} = {
        services.hyprpolkitagent.enable = true;
      };

      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
        withUWSM = true;
      };

      programs.uwsm = {
        enable = true;
      };
    };
}
