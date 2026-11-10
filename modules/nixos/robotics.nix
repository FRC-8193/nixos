{ pkgs, team, ... }:
{
  # Vendor tools often ship FHS binaries outside nixpkgs.
  programs.nix-ld.enable = true;
  virtualisation.docker.enable = team.enableDocker;

  services.udev.extraRules = ''
    # USB devices and HID adapters used for microcontrollers, radios and controllers.
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", MODE="0664", GROUP="plugdev"
    KERNEL=="hidraw*", MODE="0660", GROUP="plugdev"
    # Serial adapters (roboRIO consoles, Arduino, USB UART).
    SUBSYSTEM=="tty", GROUP="dialout", MODE="0660"
  '';

  environment.systemPackages = with pkgs; [
    # General build toolchain
    gnumake cmake ninja gcc clang clang-tools gdb pkg-config ccache
    # Robotics / embedded and serial
    openocd avrdude dfu-util can-utils minicom tio picocom screen
    # Robot network diagnostics
    nmap iperf3 tcpdump mtr socat bind.dnsutils ethtool
    # Team productivity / documentation
    libreoffice-fresh
  ];
}
