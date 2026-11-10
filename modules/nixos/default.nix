{ ... }:
{
  imports = [
    ./base.nix      # nix settings, boot, user account, locale
    ./services.nix  # ssh, printing, avahi, bluetooth, power, ...
    ./desktop.nix   # Hyprland, login screen, audio, fonts, file manager, chromium
    ./robotics.nix  # dev tools, serial/USB access, network debugging
    ./home.nix      # wires up Home Manager (the user-level config in modules/home)
  ];
}
