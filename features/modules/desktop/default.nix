{ self, ... }:
{
  flake.nixosModules.modulesDesktop =
    { ... }:
    {
      imports = [
        self.nixosModules.modulesDesktopEww
        self.nixosModules.modulesDesktopLy
        self.nixosModules.modulesDesktopStylix
        self.nixosModules.modulesDesktopXdg
        self.nixosModules.modulesDesktopNiri
      ];

      home-manager.backupFileExtension = "hm-backup";
    };
}
