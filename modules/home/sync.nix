# Files Home Manager links into ~/.config are READ-ONLY (they live in the Nix store).
# Neovim plugin managers write lock files into their config folder, so that folder must
# be a real, writable copy. `team.sync.<name> = { src; dest; }` copies src into ~/<dest>
# whenever src changes (i.e. after you edit the repo and rebuild), and otherwise leaves
# local changes alone.
{ config, lib, pkgs, ... }:
let
  cfg = config.team.sync;
in
{
  options.team.sync = lib.mkOption {
    default = { };
    description = "Directories copied (writable) from the Nix store into $HOME.";
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        src = lib.mkOption { type = lib.types.str; description = "Store path to copy from."; };
        dest = lib.mkOption { type = lib.types.str; description = "Target, relative to $HOME."; };
        exclude = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "rsync exclude patterns (files that must survive a re-sync).";
        };
      };
    });
  };

  config.home.activation = lib.mapAttrs'
    (name: s:
      lib.nameValuePair "teamSync-${name}" (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        marker="$HOME/.local/state/team-sync/${name}"
        if [ ! -e "$marker" ] || [ "$(cat "$marker")" != "${s.src}" ]; then
          $DRY_RUN_CMD mkdir -p "$HOME/${s.dest}" "$(dirname "$marker")"
          $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync -rltE --chmod=Du+rwx,Fu+rw \
            ${lib.concatMapStringsSep " " (e: "--exclude=${lib.escapeShellArg e}") s.exclude} \
            "${s.src}/" "$HOME/${s.dest}/"
          $DRY_RUN_CMD sh -c 'printf %s "$1" > "$2"' _ "${s.src}" "$marker"
        fi
      ''))
    cfg;
}
