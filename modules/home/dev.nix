# Developer and FRC toolchain. Robot projects should use their checked-in
# Gradle wrapper and season-pinned WPILib/vendor dependencies.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Java / Gradle (WPILib season toolchain)
    jdk17 gradle
    # C / C++ and native debugging
    clang clang-tools cmake ninja gnumake gdb pkg-config ccache
    # Python robotics / scripting
    python3 uv python3Packages.pyserial python3Packages.numpy
    python3Packages.pip python3Packages.virtualenv
    # Other useful tooling
    nodejs_22 rustc cargo
    # Git and code quality
    gh git-lfs lazygit
    lua-language-server nil pyright
    # Embedded / hardware
    openocd avrdude dfu-util minicom tio picocom
    # Network diagnostics
    nmap iperf3 tcpdump mtr socat
  ];
}
