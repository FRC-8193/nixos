-- Things that start with the session.
local paths = require("nix_paths")

hl.on("hyprland.start", function()
  hl.exec_cmd("qs -c team")                                   -- the desktop shell
  hl.exec_cmd(paths.polkit_agent)                             -- password prompts for admin tasks
  hl.exec_cmd("hypridle")                                     -- auto lock / suspend
  hl.exec_cmd("wl-paste --type text --watch cliphist store")  -- clipboard history (text)
  hl.exec_cmd("wl-paste --type image --watch cliphist store") -- clipboard history (images)
end)
