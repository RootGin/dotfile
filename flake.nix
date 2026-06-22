{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nix-flatpak.url = "github:gmodena/nix-flatpak/v0.6.0";
    nix-chromium-webapps.url = "github:chobbledotcom/nix-chromium-webapps";
    firefox-addons.url = "gitlab:rycee/nur-expressions/?dir=pkgs/firefox-addons";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };

    zen-findbar = {
      url = "github:RobotoSkunk/zen-better-findbar";
      flake = false;
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcord = {
      url = "github:FlameFlag/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf.url = "github:notashelf/nvf";
    vicinae = {
      url = "github:vicinaehq/vicinae/v0.20.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode-desktop.url = "github:tomsch/opencode-desktop-nix";

    niri.url = "github:sodiboo/niri-flake";

    fcitx5-lotus = {
      url = "github:LotusInputMethod/fcitx5-lotus";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { self, inputs, ... }:
      {
        imports = [
          (inputs.import-tree ./features)
          (inputs.import-tree ./hosts)
        ];

      }
    );
}
