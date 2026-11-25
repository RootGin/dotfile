{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./fastfetch
    ./netorbit.nix
  ];

  environment.systemPackages =
    with pkgs;
    [
      btop
      resources
      vulnix
    ]
    ++ lib.optionals config.my.desktop.enable [ pkgs.cava ];
}
