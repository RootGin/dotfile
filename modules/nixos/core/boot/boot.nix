{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.boot.grub.enable =
    lib.mkEnableOption "GRUB with the custom theme (instead of systemd-boot)";

  config = lib.mkMerge [
    {
      boot = {
        loader = {
          timeout = 3;

          efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/boot";
          };
        };

        kernelPackages = pkgs.linuxPackages_latest;

        kernelParams = [
          "psmouse.synaptics_intertouch=0"
          "quiet"
        ];

        plymouth.enable = true;
      };
    }

    (lib.mkIf (!config.my.boot.grub.enable) {
      boot.loader.systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
    })

    (lib.mkIf config.my.boot.grub.enable {
      boot.loader = {
        systemd-boot.enable = false;

        grub = {
          enable = true;
          device = "nodev";
          useOSProber = true;
          efiSupport = true;
          configurationLimit = 10;
          theme = ./grub-themes/loq-15arp10e;
        };
      };

      stylix.targets.grub.enable = false;
    })
  ];
}
