{ self, inputs, ... }:
{
  flake.nixosModules.coreNixBtrfs = {
    # NOTE: the root filesystem on this host is ext4 (see
    # hosts/Laptop/hardware-configuration.nix), not Btrfs. Running
    # `btrfs scrub`/`btrfs balance` against it fails every week, so both
    # are disabled until/unless the filesystem is actually converted.
    services.btrfs.autoScrub = {
      enable = false;
      interval = "weekly";
      fileSystems = [ "/" ];
    };

    # Scheduled Btrfs balance (for space efficiency)
    systemd.timers."btrfs-balance" = {
      enable = false;
      timerConfig = {
        OnCalendar = "weekly";
        RandomizedDelaySec = "1h"; # Spread load a bit
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
    systemd.services."btrfs-balance" = {
      script = ''
        # Only run if system is on AC (laptop check)
        if command -v upower >/dev/null && upower -i $(upower -e | grep BAT) | grep -q 'state:\s*discharging'; then
          echo "On battery, skipping btrfs balance"
          exit 0
        fi

        # Start a limited balance (data and metadata chunks >75% usage)
        /run/current-system/sw/bin/btrfs balance start -dusage=75 -musage=75 -susage=75 -v --background /
      '';
      serviceConfig = {
        Type = "oneshot";
        Nice = 19;
        IOSchedulingClass = "idle";
        IOSchedulingPriority = 7;
        CPUWeight = 1;
      };
    };

    # Scheduled filesystem trim (works on ext4 and Btrfs)
    services.fstrim = {
      enable = true;
      interval = "weekly";
    };
  };
}
