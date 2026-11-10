# Hyprland is configured in Lua (Hyprland 0.55+): config/hypr/*.lua.
# Files are individual read-only links so we can add generated files next to them.
{ lib, pkgs, ... }:
let
  hyprFiles = [
    "hyprland.lua" # entry point, just require()s the others
    "env.lua"
    "general.lua"  # look & feel, input, window rules
    "execs.lua"    # what starts with the session
    "keybinds.lua" # the team keybinds
    "hypridle.conf"
    "hyprlock.conf"
  ];
  scriptFiles = [ "ocr.sh" "record.sh" ];
in
{
  xdg.configFile =
    lib.listToAttrs (map
      (f: lib.nameValuePair "hypr/${f}" { source = ../../config/hypr + "/${f}"; })
      hyprFiles)
    // lib.listToAttrs (map
      (f: lib.nameValuePair "hypr/scripts/${f}" {
        source = ../../config/hypr/scripts + "/${f}";
        executable = true;
      })
      scriptFiles)
    // {
      # Nix store paths that the Lua config needs (see execs.lua).
      "hypr/nix_paths.lua".text = ''
        return {
          polkit_agent = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1",
        }
      '';
    };
}
