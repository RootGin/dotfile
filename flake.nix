{
  description = "My NixOS Configuration";

  nixConfig = {
    extra-substituters = [
      "https://vicinae.cachix.org"
      "https://devenv.cachix.org"
      "https://zed-industries.cachix.org"
    ];
    extra-trusted-public-keys = [
      "vicinae.cachix.org-1:1kDrfgsx52l9AAlVbeoal8e9sp0ckWBttqzs2bWb9/8="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "zed-industries.cachix.org-1:5b6JRtm9/B8/iSpxa85dG73HwN/kZ+dfyW1f1Tj5Dmg="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/v0.6.0";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions/?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
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

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae = {
      url = "github:vicinaehq/vicinae/v0.20.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ponytail = {
      url = "github:DietrichGebert/ponytail";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      mkHost =
        hostPath:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs self; };
          modules = [ hostPath ];
        };
    in
    {
      nixosConfigurations = {
        Laptop = mkHost ./hosts/laptop;
        thumb = mkHost ./hosts/thumb;
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
