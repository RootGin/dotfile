{
  config,
  lib,
  pkgs,
  ...
}:
{
  services = {
    node-red.enable = false;


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
}
