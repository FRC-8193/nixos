# Per-machine settings. `scripts/new-host.sh <name>` copies this file to hosts/<name>/.
# Keep this small: anything the whole team shares belongs in modules/ or team.nix.
{ ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # --- Uncomment what applies to THIS machine -------------------------------

  # BIOS (non-UEFI) machine: replace the default systemd-boot with GRUB.
  # boot.loader.systemd-boot.enable = false;
  # boot.loader.efi.canTouchEfiVariables = false;
  # boot.loader.grub = { enable = true; device = "/dev/sda"; };

  # NVIDIA GPU:
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia = { modesetting.enable = true; open = true; };
}
