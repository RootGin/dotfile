{
  imports = [
    ./gnome.nix
    ./fwupd.nix
    ./gvfs.nix
    ./nm-applet.nix
    ./power-profiles-daemon.nix
    ./rtkit.nix
    ./ssh.nix
    ./upower.nix
  ];

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
