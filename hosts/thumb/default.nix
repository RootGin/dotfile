{
  imports = [
    ../../modules/nixos
    ../common
    ../../profiles/server.nix
    ./modules/userOptions.nix
    ./modules/services.nix
    ./hardware-configuration.nix
  ];
}
