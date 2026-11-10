{ lib, pkgs, team, ... }:
{
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = team.sshAuthorizedKeys == [ ];
      KbdInteractiveAuthentication = false;
    };
  };

  services.printing = {
    enable = team.enablePrinting;
    drivers = with pkgs; [ gutenprint hplip brlaser cups-filters ];
  };
  programs.system-config-printer.enable = team.enablePrinting;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;

  networking.firewall.enable = true;
}
