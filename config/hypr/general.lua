-- Look & feel, input, window/layer rules.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
    border_size = 2,
    ["col.active_border"] = "rgba(7aa2f7ee) rgba(bb9af7ee) 45deg",
    ["col.inactive_border"] = "rgba(3b4261aa)",
    layout = "dwindle",
    resize_on_border = true,
  },
  decoration = {
    rounding = 12,
    blur = { enabled = true, size = 6, passes = 2 },
    shadow = { enabled = true, range = 12, render_power = 3, color = "rgba(00000066)" },
  },
  animations = { enabled = true },
  input = {
    kb_layout = "us",
    follow_mouse = 1,
    numlock_by_default = true,
    touchpad = { natural_scroll = true, disable_while_typing = true },
  },
  dwindle = { pseudotile = true, preserve_split = true },
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    vfr = true,
    focus_on_activate = true,
  },
  cursor = { zoom_factor = 1.0 },
})

hl.curve("ease", { type = "bezier", points = { { 0.25, 0.9 }, { 0.1, 1.0 } } })
hl.animation({ leaf = "global", enabled = true, speed = 4, bezier = "ease" })
hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "ease", style = "popin 92%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "ease", style = "slide" })

-- Floating utility windows
hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true, size = "800 500", center = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true })
hl.window_rule({ match = { class = "^(org.kde.polkit-kde-authentication-agent-1)$" }, float = true, center = true })

-- Let the compositor blur the translucent shell panels
hl.layer_rule({ match = { namespace = "^team-" }, blur = true, ignore_alpha = 0.3 })
