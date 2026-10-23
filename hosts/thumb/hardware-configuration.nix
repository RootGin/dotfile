# PLACEHOLDER - replace with the real `nixos-generate-config` output once hardware exists.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  boot.loader.systemd-boot.enable = true;

  fileSystems."/" = {
    device = "/dev/dummy";
    fsType = "ext4";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
