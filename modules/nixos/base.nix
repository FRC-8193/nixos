{ config, lib, pkgs, team, ... }:
{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 21d";
    };
    optimise.automatic = true;
  };
  nixpkgs.config.allowUnfree = true;

  # UEFI defaults; host-specific BIOS settings can override these.
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 10;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  hardware.enableRedistributableFirmware = lib.mkDefault true;
  zramSwap.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;

  networking.networkmanager.enable = true;
  time.timeZone = team.timeZone;
  i18n.defaultLocale = team.locale;

  users.groups.plugdev = { };
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  users.users.${team.userName} = {
    isNormalUser = true;
    description = team.fullName;
    initialHashedPassword = lib.mkIf (team.initialHashedPassword != null)
      team.initialHashedPassword;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" "dialout" "plugdev" "lp" ]
      ++ lib.optional config.virtualisation.docker.enable "docker";
    openssh.authorizedKeys.keys = team.sshAuthorizedKeys;
  };

  environment.systemPackages = with pkgs; [
    git curl wget unzip zip p7zip file tree
    htop btop ripgrep fd jq
    pciutils usbutils lsof psmisc
  ];

  system.stateVersion = team.stateVersion;
}
