{ ... }:
{
  imports = [
    ./bluetooth
    ./graphics
    ./network
    ./pipewire
    ./webcam
  ];

  # Windows dual-boot: use local time for hardware clock
  time.hardwareClockInLocalTime = true;

  # Power management
  powerManagement = {
    enable = true;
  };

  zramSwap = {
    enable = true;
    priority = 100;
    memoryPercent = 50;
    algorithm = "zstd";
  };

  boot.kernel.sysctl = {
    # Optimize memory management for zram
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;
    "vm.vfs_cache_pressure" = 50;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 20;
  };

  hardware.block.scheduler = {
    "nvme[0-9]*" = "kyber";
  };
}
