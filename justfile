flake := "/etc/nixos"

default:
    @just --list

build:
    sudo nixos-rebuild switch --flake {{flake}}

up:
    nix flake update --flake {{flake}}

gc:
    sudo nix-collect-garbage -d
