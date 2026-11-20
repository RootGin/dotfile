{ lib, ... }:
{
  programs.ssh.extraConfig = ''
    Host *
      AddKeysToAgent yes
  '';
  services.openssh = {
    enable = lib.mkDefault false;
    ports = [ 4545 ];
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      KbdInteractiveAuthentication = lib.mkDefault false;
      PermitRootLogin = lib.mkDefault "no";
      MaxAuthTries = lib.mkDefault 3;
      X11Forwarding = false;
    };
  };
}
