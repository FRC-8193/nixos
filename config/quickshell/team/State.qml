pragma Singleton
import QtQuick
import Quickshell

// Which panels are open, plus a few helpers shared by everything.
Singleton {
  id: root

  property bool barVisible: true
  property bool searchOpen: false
  property string searchMode: "apps" // apps | clipboard | emoji
  property bool overviewOpen: false
  property bool leftOpen: false
  property bool rightOpen: false
  property bool mediaOpen: false
  property bool sessionOpen: false
  property bool cheatsheetOpen: false
  property bool wallpaperOpen: false

  property bool showWorkspaceNumbers: false
  property bool superMightTrigger: false
  property string wallpaper: ""

  readonly property bool sidePanelOpen: leftOpen || rightOpen || mediaOpen

  function closeAll() {
    searchOpen = false; overviewOpen = false; leftOpen = false; rightOpen = false
    mediaOpen = false; sessionOpen = false; cheatsheetOpen = false; wallpaperOpen = false
  }

  function toggle(prop) {
    const next = !root[prop]
    closeAll()
    root[prop] = next
  }

  function toggleSearch(mode) {
    const wasOpen = searchOpen && searchMode === mode
    closeAll()
    searchMode = mode
    searchOpen = !wasOpen
  }

  function focusWorkspace(i) {
    // Lua-mode Hyprland: `hyprctl eval`; the dispatch fallback covers older setups.
    Quickshell.execDetached(["sh", "-c",
      "hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = \"" + i + "\" }))' || hyprctl dispatch workspace " + i])
  }

  function setWallpaper(path) {
    wallpaper = path
    Quickshell.execDetached(["sh", "-c",
      "mkdir -p \"$HOME/.local/state/team-shell\" && printf '%s' \"$1\" > \"$HOME/.local/state/team-shell/wallpaper\"", "_", path])
  }
}
