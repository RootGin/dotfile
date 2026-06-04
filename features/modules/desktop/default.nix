{ self, ... }:
{
  flake.nixosModules.modulesDesktop = {
    imports = [
      self.nixosModules.modulesDesktopEww
      self.nixosModules.modulesDesktopNiri
      self.nixosModules.modulesDesktopLy
      self.nixosModules.modulesDesktopStylix
      self.nixosModules.modulesDesktopXdg
    ];
    programs.dconf.enable = true;
  };
}
