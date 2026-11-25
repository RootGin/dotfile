{ config, lib, ... }:
let
  username = config.my.user.username;
in
{
  imports = [
    ./gvfs.nix
    ./ssh.nix
  ];

  config = lib.mkMerge [
    {
      # Cap journald log buffers in RAM/storage
      services.journald.settings.Journal = {
        SystemMaxUse = "100M";
        RuntimeMaxUse = "50M";
      };

      # Disable speech-dispatcher to save background processes when text-to-speech isn't used
      systemd.user = {
        services."speech-dispatcher".enable = false;
        sockets."speech-dispatcher".enable = false;
      };
    }

    (lib.mkIf config.my.desktop.enable {
      services = {
        gnome.gnome-keyring.enable = true;
        power-profiles-daemon.enable = true;
        upower.enable = true;
      };
      security.rtkit.enable = true;
      home-manager.users.${username} = _: {
        services.network-manager-applet.enable = true;
      };
    })
  ];
}
