{
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
    ./gc.nix
    ./settings.nix
  ];

  system = {
    autoUpgrade = {
      enable = true;
      flake = "${dots}";
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
    libraries = [
      pkgs.stdenv.cc.cc.lib
    ]
    ++ lib.optionals config.my.desktop.enable (pkgs.steam-run.args.multiPkgs pkgs);
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
