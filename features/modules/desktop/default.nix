{ self, inputs, ... }:
{
  flake.nixosModules.modulesDesktop = {
    imports = [
      self.nixosModules.modulesDesktopEww
      self.nixosModules.modulesDesktopGreetd
      self.nixosModules.modulesDesktopNiri
      self.nixosModules.modulesDesktopStylix
      self.nixosModules.modulesDesktopXdg
    ];
    programs.dconf.enable = true;

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
}
