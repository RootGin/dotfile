{ self, inputs, ... }:
{
  flake.nixosModules.hostLaptopModulesServices =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      services = {
        node-red.enable = true;

        gvfs.package = pkgs.gvfs.overrideAttrs (old: {
          mesonFlags = old.mesonFlags ++ [ "-Dgphoto2=false" ];
        });

        logind.settings.Login = {
          HandleLidSwitch = "ignore";
          HandleLidSwitchExternalPower = "ignore";
          HandleLidSwitchDocked = "ignore";
          HandleSuspendKey = "ignore";
          HandleHibernateKey = "ignore";
        };
      };

      systemd = {
        user.services = {
          "obex".enable = false;
          "dbus-org.bluez.obex".enable = false;
        };

        sleep.settings.Sleep = {
          AllowSuspend = false;
          AllowHibernation = false;
          AllowHybridSleep = false;
          AllowSuspendThenHibernate = false;
        };
      };
    };
}