# PLACEHOLDER - replace with the real `nixos-generate-config` output once hardware exists.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  # mkForce: features/system/boot/boot.nix hardcodes GRUB for the Laptop.
  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkForce true;

  fileSystems."/" = {
    device = "/dev/dummy";
    fsType = "ext4";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
