# neovim: the config in config/nvim/ is COPIED to ~/.config/nvim (writable, so plugin
# managers can write lock files). Replace config/nvim/ with your own config.
{ lib, pkgs, ... }:
let
  optPkgs = set: names: lib.filter (p: p != null) (map (n: set.${n} or null) names);
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    # Tools plugin managers / LSP setups commonly expect on PATH.
    extraPackages = (with pkgs; [
      gcc gnumake tree-sitter nodejs unzip ripgrep fd git
      lua-language-server nil clang-tools pyright
    ]) ++ optPkgs pkgs [ "nixfmt" "stylua" ];
  };

  team.sync.nvim = {
    src = "${../../config/nvim}";
    dest = ".config/nvim";
    exclude = [ "lazy-lock.json" ]; # keep local plugin versions across re-syncs
  };
}
