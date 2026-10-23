{
  imports = [
    ../../modules/nixos
    ../common
    ../../profiles/workstation.nix
    ./hardware-configuration.nix
    ./modules
  ];

  my.boot.grub.enable = true;
}
