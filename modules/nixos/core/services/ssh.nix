{ lib, ... }:
{
  programs.ssh.extraConfig = ''
    Host *
      AddKeysToAgent yes
      IdentityFile ~/.ssh/id_ed25519
  '';
  services.openssh = {
    enable = true;
    ports = [ 4545 ];
    settings.PasswordAuthentication = lib.mkDefault false;
    settings.KbdInteractiveAuthentication = lib.mkDefault false;
    settings.X11Forwarding = false;
  };
}
