# PLACEHOLDER. Not bootable. It only exists so `nix flake check` can evaluate this repo.
# On a real machine, scripts/new-host.sh replaces it with /etc/nixos/hardware-configuration.nix.
{ lib, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  fileSystems."/" = { device = "/dev/disk/by-label/nixos"; fsType = "ext4"; };
}
