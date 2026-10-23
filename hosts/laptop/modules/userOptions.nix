{ self, inputs, ... }:
{
  flake.nixosModules.hostLaptopModulesUserOptions =
    { config, ... }:
    {
      config.my.user = {
        browser = "zen-twilight";
        colorScheme = "nord";
        spicetifyColorScheme = "Nord";
        dots = "/etc/nixos";
        hostName = "Laptop";
        username = "rootgin";
        wallpaper = "nord.png";
      };
    };
}
