{ self, inputs, ... }:
{
  flake.nixosModules.modulesDesktop =
    { config, pkgs, ... }:
    let
      username = config.userOptions.username;
    in
    {
      imports = [
        self.nixosModules.modulesDesktopEww
        self.nixosModules.modulesDesktopNiri
        self.nixosModules.modulesDesktopWaybar
        self.nixosModules.modulesDesktopLy
        self.nixosModules.modulesDesktopStylix
        self.nixosModules.modulesDesktopXdg
        inputs.fcitx5-lotus.nixosModules.fcitx5-lotus
        inputs.home-manager.nixosModules.home-manager
      ];
      programs.dconf.enable = true;
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.waylandFrontend = true;
      };
      services.fcitx5-lotus = {
        enable = true;
        users = [ username ];
      };
      home-manager.users.${username} = {
        home.file.".config/fcitx5/profile".text = ''
          [Groups/0]
          Name=Default
          Default Layout=us
          DefaultIM=keyboard-us

          [Groups/0/Items/0]
          Name=keyboard-us
          Layout=us

          [Groups/0/Items/1]
          Name=Lotus
          Layout=
        '';
      };
    };
}
