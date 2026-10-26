{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  dots = config.my.user.dots;
  username = config.my.user.username;
in
{
  imports = [
    ./btrfs.nix
    ./gc.nix
    ./settings.nix
  ];

  system = {
    autoUpgrade = {
      enable = true;
      flake = "${config.my.user.dots}";
      flags = [
        "-L"
        "--update-input"
        "nixpkgs"
      ];
      dates = "weekly";
    };
    stateVersion = "26.05";
  };

  nix = {
    package = pkgs.nixVersions.latest;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
  };

  home-manager.users.${username} = {
    home.stateVersion = "26.05";
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
      "org/cinnamon/desktop/applications/terminal" = {
        exec = "kitty";
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.nh = {
    enable = true;
    flake = "${dots}";
  };

  programs.nix-ld = {
    enable = true;
    libraries = (pkgs.steam-run.args.multiPkgs pkgs) ++ [
      pkgs.stdenv.cc.cc.lib
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ ];
  };

  environment.systemPackages =
    with pkgs;
    [
      sbctl
    ]
    ++ lib.optionals config.my.desktop.enable [
      better-control
    ];
}
