{
  description = "Robotics team NixOS: Hyprland (Lua config) + a Quickshell desktop shell, kitty, zsh, neovim";

  # Only nixpkgs and Home Manager. Everything else (Hyprland config, the Quickshell
  # shell, zsh/nvim config) lives in this repo under config/.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      team = import ./team.nix;

      # Every folder in ./hosts that has a hardware-configuration.nix becomes a
      # buildable host: `nixos-rebuild switch --flake .#<folder-name>`
      hostDirs = lib.filterAttrs
        (name: type:
          type == "directory"
          && builtins.pathExists (./hosts + "/${name}/hardware-configuration.nix"))
        (builtins.readDir ./hosts);

      mkHost = hostName: lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs team hostName; };
        modules = [
          ./modules/nixos
          (./hosts + "/${hostName}")
          home-manager.nixosModules.home-manager
          { networking.hostName = hostName; }
        ];
      };
    in
    {
      nixosConfigurations = lib.mapAttrs (name: _: mkHost name) hostDirs;

      devShells.x86_64-linux.default =
        let pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in pkgs.mkShell {
          packages = with pkgs; [
            git git-lfs gh
            jdk17 gradle
            gcc clang clang-tools cmake ninja gnumake gdb pkg-config ccache
            python3 uv python3Packages.pyserial python3Packages.numpy
            nodejs_22 rustc cargo
            jq yq-go ripgrep fd fzf
            shellcheck shfmt nixfmt-rfc-style statix deadnix
            usbutils pciutils minicom tio picocom openocd
            nmap iperf3 tcpdump mtr socat
          ];
          shellHook = ''
            echo "FRC robotics development shell"
            echo "Use the project's ./gradlew wrapper for reproducible robot builds."
          '';
        };
    };
}
