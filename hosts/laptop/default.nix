{
  imports = [
    ../../profiles/workstation.nix
    ./hardware-configuration.nix
    ./modules/hardware.nix
    ./modules/programs.nix
    ./modules/service.nix
    ./modules/userOptions.nix
  ];

  my.boot.grub.enable = true;
}
