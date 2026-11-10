# Home Manager configuration for the shared team account.
{ team, ... }:
{
  imports = [
    ./sync.nix
    ./hyprland.nix
    ./shell.nix
    ./kitty.nix
    ./zsh.nix
    ./dev.nix
    ./neovim.nix
  ];

  home.stateVersion = team.stateVersion;
  programs.home-manager.enable = true;
}
