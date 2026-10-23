{
  inputs,
  config,
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
    inputs.home-manager.nixosModules.home-manager
  ];

  system = {
    autoUpgrade = {
      enable = true;
      flake = "${config.my.user.dots}";
      flags = [
        "-L"
      ];
      dates = "weekly";
      upgrade = true;
    };
    systemBuilderCommands = ''
      ln -sv ${pkgs.path} $out/nixpkgs
    '';
    stateVersion = "26.05";
  };

  nix = {
    package = pkgs.nixVersions.latest;
    nixPath = [ "nixpkgs=/run/current-system/nixpkgs/" ];
  };

  home-manager.users.${username} = {
    home.stateVersion = "26.05";
    nixpkgs.config.allowUnfree = true;
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

  environment.systemPackages = with pkgs; [
    better-control
    sbctl
  ];
}
