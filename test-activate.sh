#!/usr/bin/env bash
# Reusable "try this commit live" helper. Run as your normal user, not with sudo;
# it only escalates for the activation step.
#
#   ./test-activate.sh            build + activate .#Laptop in test mode
#   ./test-activate.sh thumb      another host (don't activate thumb on the Laptop)
#   ./test-activate.sh --revert   re-activate the generation you booted into
#
# "test" activates the config without adding a boot entry, so a reboot always
# returns you to the known-good generation.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

if [ "${1:-}" = "--revert" ]; then
  echo "Reverting to the booted system profile..."
  sudo /run/booted-system/bin/switch-to-configuration test
  exit 0
fi

[ "$(id -u)" -ne 0 ] || { echo "run as your user, not root"; exit 1; }

host="Laptop"
if [ $# -gt 0 ] && [[ "$1" != -* ]]; then
  host="$1"
  shift
fi

echo "Commit: $(git log -1 --format='%h %s')"
git diff --quiet && git diff --cached --quiet || echo "warning: uncommitted tracked changes"
if git status --porcelain | grep -q '^??'; then
  echo "warning: untracked files are ignored by nix flakes"
fi

# Build as your user: root evaluating a user-owned git repo can hit
# "dubious ownership" errors and leave root-owned files behind.
out=$(nix build ".#nixosConfigurations.$host.config.system.build.toplevel" \
        --no-link --print-out-paths "$@")

if command -v nvd >/dev/null; then
  nvd diff /run/current-system "$out" || true
fi

sudo "$out/bin/switch-to-configuration" test
echo "Active (test mode): $out"
echo "Undo now: ./test-activate.sh --revert   |   or just reboot."
