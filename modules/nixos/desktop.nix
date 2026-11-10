{ lib, pkgs, ... }:
let
  # Look a package up by name and quietly skip it if this nixpkgs doesn't have it.
  optPkgs = set: names: lib.filter (p: p != null) (map (n: set.${n} or null) names);
  xfce = n: pkgs.${n} or pkgs.xfce.${n} or null;
in
{
  # ---- Hyprland + login screen -------------------------------------------
  programs.hyprland.enable = true; # compositor, session entry, portal
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.displayManager.defaultSession = "hyprland";

  security.pam.services.hyprlock = { }; # lets the lock screen check your password
  security.pam.services.sddm.enableGnomeKeyring = true;
  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.hyprland.default = [ "hyprland" "gtk" ];
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # Chromium/Electron use Wayland

  # ---- Audio ---------------------------------------------------------------
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # ---- Fonts (the shell uses Material Symbols, Rubik, Gabarito, a Nerd Font) --
  fonts = {
    enableDefaultPackages = true;
    packages = [
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk-sans
    ] ++ optPkgs pkgs [ "noto-fonts-color-emoji" "material-symbols" "rubik" "gabarito" "readex-pro" ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "Rubik" "Noto Sans" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # ---- Apps ---------------------------------------------------------------
  programs.thunar = {
    enable = true; # file manager (Super+E)
    plugins = lib.filter (p: p != null) [ (xfce "thunar-archive-plugin") (xfce "thunar-volman") ];
  };
  programs.xfconf.enable = true; # lets Thunar save its settings

  programs.chromium.enable = true; # policy support
  environment.systemPackages = [ pkgs.chromium pkgs.file-roller ];
}
