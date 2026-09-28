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
        # self.nixosModules.modulesDesktopHypr
        # self.nixosModules.modulesDesktopWaybar
        self.nixosModules.modulesDesktopLy
        self.nixosModules.modulesDesktopStylix
        self.nixosModules.modulesDesktopXdg
        self.nixosModules.modulesDesktopNiri
      ];

      home-manager.backupFileExtension = "hm-backup";
    };
}
