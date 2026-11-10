# Quickshell desktop UI and every executable called by its QML, keybinds and scripts.
{ lib, pkgs, ... }:
let
  optPkgs = set: names: lib.filter (p: p != null) (map (n: set.${n} or null) names);
  xfce = n: pkgs.${n} or pkgs.xfce.${n} or null;
in
{
  xdg.configFile."quickshell/team".source = ../../config/quickshell/team;

  home.packages = with pkgs; [
    quickshell

    # Hyprland session / lock / idle
    hypridle hyprlock hyprpicker hyprshot
    # Screenshots, capture, OCR, clipboard
    grim slurp wl-clipboard cliphist wf-recorder tesseract
    # Launcher and session fallback
    fuzzel wlogout
    # Audio, brightness, media, network, notifications
    playerctl pavucontrol brightnessctl libnotify networkmanagerapplet
    mako
    # Shell/keybind dependencies
    bc procps coreutils findutils gnugrep gawk gnused
    # Visual polish and icons
    adw-gtk3 papirus-icon-theme bibata-cursors
    # Images, video and utility helpers
    imagemagick ffmpeg jq xdg-user-dirs xdg-utils
    # File manager and archive integration
    thunar file-roller
  ] ++ optPkgs pkgs.kdePackages [ "polkit-kde-agent-1" ]
    ++ optPkgs pkgs [ "material-symbols" "rubik" "gabarito" "readex-pro" ];
}
