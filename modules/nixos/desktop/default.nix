{ ... }:
{
  imports = [
    ./options.nix
    ./eww
    ./ly
    ./stylix
    ./xdg
    ./niri
  ];

  home-manager.backupFileExtension = "hm-backup";
}
