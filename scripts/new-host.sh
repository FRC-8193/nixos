#!/usr/bin/env bash
# Register a machine. Hosts are discovered by flake.nix when hardware-configuration.nix exists.
# Usage: scripts/new-host.sh [hostname]
set -euo pipefail
cd "$(dirname "$0")/.."

host="${1:-$(hostname)}"
if [[ ! "$host" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*$ ]]; then
  echo "Hostname must contain only letters, digits and dashes (got: $host)" >&2
  exit 1
fi

dir="hosts/$host"
hw="${HW_CONFIG:-/etc/nixos/hardware-configuration.nix}"

if [[ -e "$dir" ]]; then
  echo "Host directory already exists: $dir" >&2
  echo "Refusing to overwrite it. Back it up or remove it first." >&2
  exit 1
fi

mkdir -p "$dir"
if [[ -f "$hw" ]]; then
  cp "$hw" "$dir/hardware-configuration.nix"
else
  echo "No $hw found; generating hardware configuration..."
  sudo nixos-generate-config --show-hardware-config > "$dir/hardware-configuration.nix"
fi

cp hosts/example/default.nix "$dir/default.nix"
git add -A "$dir"

cat <<MSG

Host "$host" registered in $dir/

Next:
  1. Review $dir/default.nix (GPU, bootloader, host-specific settings).
  2. Review team.nix (username, timezone, SSH public keys).
  3. Set the account password locally, or configure initialHashedPassword.
  4. Build: sudo nixos-rebuild build --flake .#$host
  5. Apply: sudo nixos-rebuild switch --flake .#$host
MSG
