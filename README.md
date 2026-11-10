# Robotics Team NixOS

A shared NixOS configuration for team laptops and workstations, using Hyprland
(Lua configuration) and Quickshell. Hosts are discovered automatically from
`hosts/*/hardware-configuration.nix`; adding a host does not require editing
`flake.nix`.

## Design

- `team.nix`: shared team identity, locale, SSH keys, Docker/printing policy.
- `hosts/<hostname>/`: hardware configuration and machine-specific overrides.
- `modules/nixos/`: system settings, desktop services, robotics hardware access.
- `modules/home/`: Home Manager desktop, Quickshell, terminal, editor and tooling.
- `config/hypr/`: Hyprland Lua config, keybinds, idle/lock and scripts.
- `config/quickshell/team/`: Quickshell UI and QML components.
- `config/zsh/`: optional team-wide additions; core shell is declared in Nix.

## Add a machine

```sh
git clone <your-repository-url> ~/robotics-nixos
cd ~/robotics-nixos
scripts/new-host.sh robot-laptop-1
```

The script copies `/etc/nixos/hardware-configuration.nix`, copies
`hosts/example/default.nix`, and stages the new host. The flake automatically
discovers every host directory containing `hardware-configuration.nix`.

Review `hosts/robot-laptop-1/default.nix` for GPU, bootloader and machine-specific
settings. Then:

```sh
sudo nixos-rebuild build --flake .#robot-laptop-1
sudo nixos-rebuild switch --flake .#robot-laptop-1
```

Do not overwrite an existing host directory with the registration script; it
refuses to do so. Back up and edit existing host definitions manually.

## Team setup and account security

Edit `team.nix` before deploying:

- Set the shared team account name and display name.
- Set the team's timezone and locale.
- Add team SSH **public** keys.
- Enable Docker only if needed.

There is no committed default password. Set the user's password from the installer
or a root shell (`passwd robotics`) before the first graphical login, or generate
a yescrypt hash locally with `mkpasswd -m yescrypt` and set
`initialHashedPassword` in a private, uncommitted local change.

SSH password authentication is automatically disabled once at least one SSH key
is configured. Confirm key-based login works before relying on remote access.

## Shell and terminal

The interactive shell is Zsh managed entirely through Home Manager:

- Completion, case-insensitive matching, autosuggestions and syntax highlighting.
- Starship prompt, fzf, zoxide, direnv + nix-direnv.
- eza, bat, ripgrep, fd, jq/yq, btop, dust, duf, procs and tldr.
- Git aliases, lazygit, delta, Git LFS and GitHub CLI.
- Nix tools: nix-tree, nix-output-monitor, nixfmt, statix and deadnix.
- tmux and zellij, shellcheck, shfmt, just, hyperfine and watchexec.
- Git defaults (main, rebase pulls, prune, rerere) without a shared student identity.
- `mkcd`, `extract`, `robot-ping`, `robot-ssh`, `serial-devices`, `frc-build`.

Personal additions can live in `~/.config/zsh/local.zsh`. Do not put tokens,
passwords, or private keys in the repository.

## Quickshell / Hyprland

Quickshell is started by `config/hypr/execs.lua` using `qs -c team`.
`modules/home/shell.nix` provides the shell and its runtime dependencies, including
the fallback launcher, screenshot/recording/OCR tools, clipboard history, audio,
brightness, network, notifications and icon/font packages.

Useful keybinds are documented in `config/hypr/keybinds.lua` and the Quickshell
cheatsheet. For live shell development:

```sh
qs -p config/quickshell/team
qs log
```

If a shell panel fails, inspect `qs log`; if a bind fails, inspect Hyprland's
configuration output and `hyprctl configerrors`.

## Robotics development

The user environment and `nix develop` shell include:

- Java 17 and Gradle.
- GCC/Clang, CMake, Ninja, GDB, pkg-config and ccache.
- Python, uv, pip, NumPy and pyserial.
- Node.js and Rust.
- USB, serial, CAN, OpenOCD and DFU utilities.
- Network diagnostics: nmap, iperf3, tcpdump, mtr and socat.

Use each robot project's checked-in Gradle wrapper (`./gradlew`) and the
season-matched WPILib release. WPILib's installer, Driver Station, and vendor
tools such as REV Hardware Client and Phoenix Tuner have upstream packaging,
licensing and release constraints, so they are not falsely represented as
included by this generic toolchain. Install and validate those separately.

## Git identity

Students should set their own identity rather than sharing one team-wide identity:

```sh
git config --global user.name "Your Name"
git config --global user.email "you@example.org"
```

## Validation

Run:

```sh
nix flake check
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

The example host hardware file is only an evaluation placeholder. Replace it
with real installer-generated hardware configuration before deploying. This
configuration has not been built or tested on physical hardware; validate
Hyprland's Lua API and Quickshell QML against the pinned nixpkgs revision.
