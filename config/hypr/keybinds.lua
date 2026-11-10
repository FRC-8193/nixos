-- Team keybinds, converted from the original hyprlang keybinds.conf (kept in
-- docs/original-keybinds.conf) to the Hyprland 0.55+ Lua API.
-- Everything lives in the "global" submap, as in the original.

local qsConfig       = "team"
local terminal       = "kitty"
local fileManager    = "thunar"
local codeEditor     = "kitty -e nvim"
local textEditor     = "kitty -e nvim"
local officeSoftware = "libreoffice"
local volumeMixer    = "pavucontrol"
local settingsApp    = "nm-connection-editor"
local taskManager    = "kitty -e btop"

local home    = os.getenv("HOME")
local scripts = home .. "/.config/hypr/scripts/"

local function g(name) return hl.dsp.global("quickshell:" .. name) end -- shell global shortcut
local function run(cmd) return hl.dsp.exec_cmd(cmd) end
local alive = "qs -c " .. qsConfig .. " ipc call TEST_ALIVE ping"
local function ifShellDead(cmd) return run(alive .. " || " .. cmd) end -- fallback when the shell isn't running
local function ipc(args) return "qs -c " .. qsConfig .. " ipc call " .. args end

-- Screen zoom (replaces zoom.sh)
local zoom = 1.0
local function setZoom(delta)
  zoom = math.max(1.0, math.min(10.0, zoom + delta))
  hl.config({ cursor = { zoom_factor = zoom } })
end

local DIRS = { Left = "left", Right = "right", Up = "up", Down = "down" }
local WS_KEYCODES = { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }
local WS_KEYPAD = { 87, 88, 89, 83, 84, 85, 79, 80, 81, 90 } -- KP 1..9, 0

hl.define_submap("global", function()
  ------------------------------------------------------------------ Shell
  -- Tapping Super toggles search; pressing any other key while Super is held cancels it.
  hl.bind("SUPER + SUPER_L", g("searchToggleRelease"), { ignore_mods = true, description = "Toggle search" })
  hl.bind("SUPER + SUPER_R", g("searchToggleRelease"), { ignore_mods = true, description = "Toggle search" })
  hl.bind("SUPER + SUPER_L", run(alive .. " || pkill fuzzel || fuzzel"))
  hl.bind("SUPER + SUPER_R", run(alive .. " || pkill fuzzel || fuzzel"))
  hl.bind("SUPER + catchall", g("searchToggleReleaseInterrupt"),
    { ignore_mods = true, transparent = true, non_consuming = true })
  hl.bind("CTRL + SUPER_L", g("searchToggleReleaseInterrupt"))
  hl.bind("CTRL + SUPER_R", g("searchToggleReleaseInterrupt"))
  for _, b in ipairs({ 272, 273, 274, 275, 276, 277 }) do
    hl.bind("SUPER + mouse:" .. b, g("searchToggleReleaseInterrupt"))
  end
  hl.bind("SUPER + mouse_up", g("searchToggleReleaseInterrupt"))
  hl.bind("SUPER + mouse_down", g("searchToggleReleaseInterrupt"))

  hl.bind("SUPER_L", g("workspaceNumber"), { ignore_mods = true, transparent = true })
  hl.bind("SUPER_R", g("workspaceNumber"), { ignore_mods = true, transparent = true })
  hl.bind("SUPER + Tab", g("overviewWorkspacesToggle"), { description = "Toggle overview" })
  hl.bind("SUPER + V", g("overviewClipboardToggle"), { description = "Clipboard history >> clipboard" })
  hl.bind("SUPER + Period", g("overviewEmojiToggle"), { description = "Emoji >> clipboard" })
  hl.bind("SUPER + A", g("sidebarLeftToggle"), { description = "Toggle left sidebar" })
  hl.bind("SUPER + B", g("sidebarLeftToggle"))
  hl.bind("SUPER + O", g("sidebarLeftToggle"))
  hl.bind("SUPER + N", g("sidebarRightToggle"), { description = "Toggle right sidebar" })
  hl.bind("SUPER + Slash", g("cheatsheetToggle"), { description = "Toggle cheatsheet" })
  hl.bind("SUPER + M", g("mediaControlsToggle"), { description = "Toggle media controls" })
  hl.bind("CTRL + ALT + Delete", g("sessionToggle"), { description = "Toggle session menu" })
  hl.bind("SUPER + J", g("barToggle"), { description = "Toggle bar" })
  hl.bind("CTRL + ALT + Delete", run(alive .. " || pkill wlogout || wlogout -p layer-shell"))

  hl.bind("XF86MonBrightnessUp", run(ipc("brightness increment") .. " || brightnessctl s 5%+"), { locked = true, repeating = true })
  hl.bind("XF86MonBrightnessDown", run(ipc("brightness decrement") .. " || brightnessctl s 5%-"), { locked = true, repeating = true })
  hl.bind("XF86AudioRaiseVolume", run("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1.5"), { locked = true, repeating = true })
  hl.bind("XF86AudioLowerVolume", run("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"), { locked = true, repeating = true })

  hl.bind("XF86AudioMute", run("wpctl set-mute @DEFAULT_SINK@ toggle"), { locked = true })
  hl.bind("SUPER + SHIFT + M", run("wpctl set-mute @DEFAULT_SINK@ toggle"), { locked = true, description = "Toggle mute" })
  hl.bind("ALT + XF86AudioMute", run("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
  hl.bind("XF86AudioMicMute", run("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
  hl.bind("SUPER + ALT + M", run("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true, description = "Toggle mic" })
  hl.bind("CTRL + SUPER + T", g("wallpaperSelectorToggle"), { description = "Wallpaper selector" })
  hl.bind("CTRL + SUPER + ALT + T", g("wallpaperSelectorRandom"), { description = "Random wallpaper" })
  hl.bind("CTRL + SUPER + R", run("killall qs quickshell; qs -c " .. qsConfig .. " &"))

  ------------------------------------------------------------------ Utilities
  hl.bind("SUPER + V", ifShellDead("pkill fuzzel || cliphist list | fuzzel --match-mode fzf --dmenu | cliphist decode | wl-copy"),
    { description = "Copy clipboard history entry" })
  hl.bind("SUPER + SHIFT + S", g("regionScreenshot"))
  hl.bind("SUPER + SHIFT + S", ifShellDead("pidof slurp || hyprshot --freeze --clipboard-only --mode region --silent"))
  hl.bind("SUPER + SHIFT + X", g("regionOcr"))
  hl.bind("SUPER + SHIFT + X", ifShellDead(scripts .. "ocr.sh"))
  hl.bind("SUPER + SHIFT + C", run("hyprpicker -a"), { description = "Pick color (Hex) >> clipboard" })

  hl.bind("SUPER + SHIFT + R", g("regionRecord"), { locked = true })
  hl.bind("SUPER + SHIFT + R", ifShellDead(scripts .. "record.sh"), { locked = true })
  hl.bind("SUPER + ALT + R", g("regionRecord"), { locked = true })
  hl.bind("SUPER + ALT + R", ifShellDead(scripts .. "record.sh"), { locked = true })
  hl.bind("CTRL + ALT + R", run(scripts .. "record.sh --fullscreen"), { locked = true })
  hl.bind("SUPER + SHIFT + ALT + R", run(scripts .. "record.sh --fullscreen --sound"), { locked = true })

  local monitor = [["$(hyprctl activeworkspace -j | jq -r '.monitor')"]]
  hl.bind("Print", run("grim -o " .. monitor .. " - | wl-copy"), { locked = true })
  hl.bind("CTRL + Print", run("mkdir -p $(xdg-user-dir PICTURES)/Screenshots && grim -o " .. monitor ..
    " $(xdg-user-dir PICTURES)/Screenshots/Screenshot_\"$(date '+%Y-%m-%d_%H.%M.%S')\".png"), { locked = true, non_consuming = true })
  hl.bind("CTRL + Print", run("grim -o " .. monitor .. " - | wl-copy"), { locked = true, non_consuming = true })

  ------------------------------------------------------------------ Window
  hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, drag = true })
  hl.bind("SUPER + mouse:274", hl.dsp.window.drag(), { mouse = true, drag = true })
  hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, drag = true })

  for key, dir in pairs(DIRS) do
    hl.bind("SUPER + " .. key, hl.dsp.focus({ direction = dir }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
  end
  hl.bind("SUPER + BracketLeft", hl.dsp.focus({ direction = "left" }))
  hl.bind("SUPER + BracketRight", hl.dsp.focus({ direction = "right" }))

  hl.bind("ALT + F4", hl.dsp.window.close())
  hl.bind("SUPER + W", hl.dsp.window.close(), { description = "Close" })
  hl.bind("SUPER + SHIFT + ALT + Q", run("hyprctl kill"), { description = "Forcefully zap a window" })

  hl.bind("SUPER + Semicolon", hl.dsp.layout("splitratio -0.1"), { repeating = true })
  hl.bind("SUPER + Apostrophe", hl.dsp.layout("splitratio +0.1"), { repeating = true })

  hl.bind("SUPER + ALT + Space", hl.dsp.window.float({ action = "toggle" }), { description = "Float/Tile" })
  hl.bind("SUPER + D", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), { description = "Maximize" })
  hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { description = "Fullscreen" })
  hl.bind("SUPER + ALT + F", hl.dsp.window.fullscreen_state({ internal = 0, client = 3 }), { description = "Fullscreen spoof" })
  hl.bind("SUPER + P", hl.dsp.window.pin({ action = "toggle" }), { description = "Pin" })

  -- Raw keycodes (not names) so number keys work on any keyboard layout. Check with `wev`.
  for i, code in ipairs(WS_KEYCODES) do
    hl.bind("SUPER + code:" .. code, hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind("SUPER + SHIFT + code:" .. code, hl.dsp.window.move({ workspace = tostring(i) }))
  end
  for i, code in ipairs(WS_KEYPAD) do
    hl.bind("SUPER + code:" .. code, hl.dsp.focus({ workspace = tostring(i) }), { dont_inhibit = true })
    hl.bind("SUPER + SHIFT + code:" .. code, hl.dsp.window.move({ workspace = tostring(i) }))
  end

  hl.bind("SUPER + SHIFT + mouse_down", hl.dsp.window.move({ workspace = "r-1" }))
  hl.bind("SUPER + SHIFT + mouse_up", hl.dsp.window.move({ workspace = "r+1" }))
  hl.bind("SUPER + ALT + mouse_down", hl.dsp.window.move({ workspace = "-1" }))
  hl.bind("SUPER + ALT + mouse_up", hl.dsp.window.move({ workspace = "+1" }))
  hl.bind("SUPER + ALT + Page_Down", hl.dsp.window.move({ workspace = "+1" }))
  hl.bind("SUPER + ALT + Page_Up", hl.dsp.window.move({ workspace = "-1" }))
  hl.bind("SUPER + SHIFT + Page_Down", hl.dsp.window.move({ workspace = "r+1" }))
  hl.bind("SUPER + SHIFT + Page_Up", hl.dsp.window.move({ workspace = "r-1" }))
  hl.bind("CTRL + SUPER + SHIFT + Right", hl.dsp.window.move({ workspace = "r+1" }))
  hl.bind("CTRL + SUPER + SHIFT + Left", hl.dsp.window.move({ workspace = "r-1" }))

  hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special", follow = false }), { description = "Send to scratchpad" })

  ------------------------------------------------------------------ Workspace
  hl.bind("CTRL + SUPER + Right", hl.dsp.focus({ workspace = "r+1" }))
  hl.bind("CTRL + SUPER + Left", hl.dsp.focus({ workspace = "r-1" }))
  hl.bind("CTRL + SUPER + ALT + Right", hl.dsp.focus({ workspace = "m+1" }))
  hl.bind("CTRL + SUPER + ALT + Left", hl.dsp.focus({ workspace = "m-1" }))
  hl.bind("SUPER + Page_Down", hl.dsp.focus({ workspace = "+1" }))
  hl.bind("SUPER + Page_Up", hl.dsp.focus({ workspace = "-1" }))
  hl.bind("CTRL + SUPER + Page_Down", hl.dsp.focus({ workspace = "r+1" }))
  hl.bind("CTRL + SUPER + Page_Up", hl.dsp.focus({ workspace = "r-1" }))
  hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "+1" }))
  hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "-1" }))
  hl.bind("CTRL + SUPER + mouse_up", hl.dsp.focus({ workspace = "r+1" }))
  hl.bind("CTRL + SUPER + mouse_down", hl.dsp.focus({ workspace = "r-1" }))
  hl.bind("SUPER + S", hl.dsp.workspace.toggle_special(), { description = "Toggle scratchpad" })
  hl.bind("SUPER + mouse:275", hl.dsp.workspace.toggle_special())
  hl.bind("CTRL + SUPER + BracketLeft", hl.dsp.focus({ workspace = "-1" }))
  hl.bind("CTRL + SUPER + BracketRight", hl.dsp.focus({ workspace = "+1" }))
  hl.bind("CTRL + SUPER + Up", hl.dsp.focus({ workspace = "r-5" }))
  hl.bind("CTRL + SUPER + Down", hl.dsp.focus({ workspace = "r+5" }))
  hl.bind("CTRL + SUPER + S", hl.dsp.workspace.toggle_special())

  ------------------------------------------------------------------ Virtual machines
  hl.bind("SUPER + ALT + F1", function()
    hl.exec_cmd("notify-send 'Entered Virtual Machine submap' 'Keybinds disabled. Hit Super+Alt+F1 to escape' -a 'Hyprland'")
    hl.dispatch(hl.dsp.submap("virtual-machine"))
  end, { description = "Disable keybinds" })

  ------------------------------------------------------------------ Session
  hl.bind("SUPER + L", run("loginctl lock-session"), { description = "Lock" })
  hl.bind("SUPER + SHIFT + L", run("systemctl suspend || loginctl suspend"), { locked = true, description = "Sleep" })
  hl.bind("CTRL + SHIFT + ALT + SUPER + Delete", run("systemctl poweroff || loginctl poweroff"), { description = "Shutdown" })

  ------------------------------------------------------------------ Screen
  hl.bind("SUPER + Minus", function() setZoom(-0.3) end, { repeating = true, description = "Zoom out" })
  hl.bind("SUPER + Equal", function() setZoom(0.3) end, { repeating = true, description = "Zoom in" })
  hl.bind("SUPER + code:82", function() setZoom(-0.1) end, { repeating = true })
  hl.bind("SUPER + code:86", function() setZoom(0.1) end, { repeating = true })

  ------------------------------------------------------------------ Media
  local nextTrack = "playerctl next || playerctl position `bc <<< \"100 * $(playerctl metadata mpris:length) / 1000000 / 100\"`"
  hl.bind("SUPER + SHIFT + N", run(nextTrack), { locked = true, description = "Next track" })
  hl.bind("XF86AudioNext", run(nextTrack), { locked = true })
  hl.bind("XF86AudioPrev", run("playerctl previous"), { locked = true })
  hl.bind("SUPER + SHIFT + ALT + mouse:275", run("playerctl previous"))
  hl.bind("SUPER + SHIFT + ALT + mouse:276", run(nextTrack))
  hl.bind("SUPER + SHIFT + B", run("playerctl previous"), { locked = true, description = "Previous track" })
  hl.bind("SUPER + SHIFT + P", run("playerctl play-pause"), { locked = true, description = "Play/pause media" })
  hl.bind("XF86AudioPlay", run("playerctl play-pause"), { locked = true })
  hl.bind("XF86AudioPause", run("playerctl play-pause"), { locked = true })

  ------------------------------------------------------------------ Apps
  hl.bind("SUPER + Return", run(terminal), { description = "Terminal" })
  hl.bind("SUPER + T", run(terminal))
  hl.bind("CTRL + ALT + T", run(terminal))
  hl.bind("SUPER + E", run(fileManager), { description = "File manager" })
  hl.bind("SUPER + C", run(codeEditor), { description = "Code editor" })
  hl.bind("CTRL + SUPER + SHIFT + ALT + W", run(officeSoftware), { description = "Office software" })
  hl.bind("SUPER + X", run(textEditor), { description = "Text editor" })
  hl.bind("CTRL + SUPER + V", run(volumeMixer), { description = "Volume mixer" })
  hl.bind("SUPER + I", run(settingsApp), { description = "Settings app" })
  hl.bind("CTRL + SHIFT + Escape", run(taskManager), { description = "Task manager" })

  hl.bind("CTRL + SUPER + Backslash", hl.dsp.window.resize({ x = 640, y = 480, relative = false }))
end)

-- Disables every keybind except the one that gets you back (for VMs / remote desktops)
hl.define_submap("virtual-machine", function()
  hl.bind("SUPER + ALT + F1", function()
    hl.exec_cmd("notify-send 'Exited Virtual Machine submap' 'Keybinds re-enabled' -a 'Hyprland'")
    hl.dispatch(hl.dsp.submap("global"))
  end)
end)

hl.on("hyprland.start", function()
  hl.dispatch(hl.dsp.submap("global"))
end)
