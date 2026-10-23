{ config, lib, ... }:
{
  config = lib.mkIf config.my.desktop.enable {
    security.pam.services.ly = {
      enableGnomeKeyring = true;
      text = ''
        auth     include login
        account  include login
        password include login
        session  include login
      '';
    };
    security.pam.services.login.enableGnomeKeyring = true;
  };
}
