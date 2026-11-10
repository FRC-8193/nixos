# A consistent team shell: fast startup, useful completions, sane history and
# predictable aliases. Personal customizations can live in config/zsh/local.zsh.
{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    history = {
      size = 50000;
      save = 50000;
      path = "${config.xdg.dataHome}/zsh/history";
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
      expireDuplicatesFirst = true;
    };
    shellAliases = {
      ls = "eza --icons";
      ll = "eza -lah --icons --git";
      la = "eza -a --icons";
      lt = "eza --tree --level=2";
      cat = "bat --paging=never";
      grep = "rg";
      find = "fd";
      top = "btop";
      df = "duf";
      du = "dust";
      gs = "git status";
      gd = "git diff";
      gds = "git diff --staged";
      gl = "git log --oneline --graph --decorate";
      ga = "git add";
      gc = "git commit";
      gco = "git switch";
      gcb = "git switch -c";
      gp = "git push";
      gpl = "git pull --rebase";
      rebuild = "sudo nixos-rebuild switch --flake .#$(hostname)";
      build = "sudo nixos-rebuild build --flake .#$(hostname)";
      update = "nix flake update";
      cleanup = "sudo nix-collect-garbage -d";
    };
    initContent = ''
      bindkey -e
      setopt AUTO_CD
      setopt INTERACTIVE_COMMENTS
      setopt HIST_VERIFY
      setopt INC_APPEND_HISTORY
      setopt HIST_FCNTL_LOCK
      setopt CORRECT
      setopt NO_BEEP

      # Better completion menu.
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

      # Useful small helpers.
      mkcd() { mkdir -p -- "$1" && cd -- "$1"; }
      extract() {
        if [[ -f "$1" ]]; then
          case "$1" in
            *.tar.gz|*.tgz) tar -xzf "$1" ;;
            *.tar.xz) tar -xJf "$1" ;;
            *.tar.bz2) tar -xjf "$1" ;;
            *.tar) tar -xf "$1" ;;
            *.zip) unzip "$1" ;;
            *.7z) 7z x "$1" ;;
            *) print -u2 "Don't know how to extract: $1"; return 1 ;;
          esac
        else
          print -u2 "File not found: $1"; return 1
        fi
      }

      # Robotics helpers require an explicit target to avoid assuming a team number.
      robot-ping() {
        [[ -n "$1" ]] || { print -u2 "usage: robot-ping <host-or-IP>"; return 2; }
        ping "$1"
      }
      robot-ssh() {
        [[ -n "$1" ]] || { print -u2 "usage: robot-ssh <user@host-or-IP>"; return 2; }
        ssh "$1"
      }
      serial-devices() {
        if [[ -d /dev/serial/by-id ]]; then
          command ls -l /dev/serial/by-id/
        else
          command ls -l /dev/ttyUSB* /dev/ttyACM* 2>/dev/null || true
        fi
      }
      frc-build() {
        [[ -x ./gradlew ]] || { print -u2 "No Gradle wrapper in current directory"; return 1; }
        ./gradlew build
      }

      [[ -f "$HOME/.config/zsh/local.zsh" ]] && source "$HOME/.config/zsh/local.zsh"
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      command_timeout = 1000;
      directory = { truncation_length = 3; truncate_to_repo = true; };
      git_branch.symbol = " ";
      git_status = { disabled = false; };
      nix_shell.symbol = " ";
      cmd_duration.min_time = 2000;
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };

  programs.zoxide = { enable = true; enableZshIntegration = true; };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [ "--height=40%" "--layout=reverse" "--border" ];
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.bat.enable = true;
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = "auto";
  };

  programs.zsh.plugins = [
    { name = "fzf-tab"; src = pkgs.zsh-fzf-tab; }
  ];

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
      fetch.prune = true;
      push.autoSetupRemote = true;
      rerere.enabled = true;
      diff.colorMoved = "default";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    historyLimit = 100000;
    shortcut = "a";
    extraConfig = ''
      set -g status-interval 5
      set -g set-clipboard on
      setw -g mode-keys vi
      set -g renumber-windows on
    '';
  };

  home.packages = with pkgs; [
    zsh-completions
    btop duf dust procs
    tealdeer
    lazygit git-lfs gh delta
    nix-tree nix-output-monitor nixfmt statix deadnix
    shellcheck shfmt just hyperfine watchexec ouch
    tmux zellij direnv
  ];
}
