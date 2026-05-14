{ self, inputs, ... }:
{
  flake.nixosModules.hostLaptopModulesUserOptions =
    { config, ... }:
    {
      config.userOptions = {
        browser = "zen-beta";
        colorScheme = "nord";
        spicetifyColorScheme = "Nord";
        discordClient = "equibop";
        dots = "/home/${config.userOptions.username}/.dotfiles";
        hostName = "Laptop";
        username = "rootgin";
        wallpaper = "nord.png";
      };
    };
}
