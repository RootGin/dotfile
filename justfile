flake := "/etc/nixos"

default:
    @just --list

build:
    sudo nixos-rebuild switch --flake {{flake}}

up:
    nix flake update --flake {{flake}}

gc:
    sudo nix-collect-garbage -d

# Print a string repeated n times, e.g. `just repeat-str = 50`
repeat-str s n:
    #!/usr/bin/env bash
    set -euo pipefail
    for ((i = 0; i < {{n}}; i++)); do printf '%s' "{{s}}"; done
    echo

# Copy a read-only dir (e.g. one linked from the Nix store) into a writable copy
make-editable path:
    #!/usr/bin/env bash
    set -euo pipefail
    just repeat-str = 50
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    rsync -av --copy-links "{{path}}/" "$tmp/"
    # if the path is a symlink into the store, drop the link so we write a real dir
    if [ -L "{{path}}" ]; then rm "{{path}}"; mkdir -p "{{path}}"; fi
    rsync -av --copy-links --chmod=D2755,F744 "$tmp/" "{{path}}"
