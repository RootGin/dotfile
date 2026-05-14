{ self, ... }:
{
  flake.nixosModules.coreBootBoot =
    { pkgs, ... }:
    {
      boot = {
        loader = {
          timeout = 30;
          systemd-boot.enable = false;

          efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/boot";
          };

          grub = {
            enable = true;
            device = "nodev";
            useOSProber = true;
            efiSupport = true;
            theme = ./grub-themes/Xenlism-Nixos;
          };
        };

        initrd.systemd.enable = true;
        kernelPackages = pkgs.linuxPackages_latest;
      };

      stylix.targets.grub.enable = false;
    };
}
