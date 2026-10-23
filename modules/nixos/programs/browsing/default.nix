{ pkgs, lib, ... }:
    {
      imports = [
        ./chromium.nix
        ./chromium-webapps.nix
        ./firefox.nix
        ./zen.nix
      ];
    }
