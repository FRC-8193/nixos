import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// Connects Hyprland global shortcuts ("quickshell:<name>" in keybinds.lua) and
// `qs -c team ipc call ...` commands to the panels.
Scope {
  readonly property string hypr: Quickshell.env("HOME") + "/.config/hypr/scripts/"

  Timer { id: numbers; interval: 400; onTriggered: State.showWorkspaceNumbers = true }

  GlobalShortcut {
    name: "searchToggleRelease"; description: "Toggle search"
    onPressed: State.superMightTrigger = true
    onReleased: {
      if (!State.superMightTrigger) return
      State.superMightTrigger = false
      State.toggleSearch("apps")
    }
  }
  GlobalShortcut {
    name: "searchToggleReleaseInterrupt"; description: "Cancel search toggle"
    onPressed: State.superMightTrigger = false
  }
  GlobalShortcut {
    name: "workspaceNumber"; description: "Show workspace numbers while Super is held"
    onPressed: numbers.restart()
    onReleased: { numbers.stop(); State.showWorkspaceNumbers = false }
  }

  GlobalShortcut { name: "overviewWorkspacesToggle"; description: "Overview"; onPressed: State.toggle("overviewOpen") }
  GlobalShortcut { name: "overviewClipboardToggle"; description: "Clipboard history"; onPressed: State.toggleSearch("clipboard") }
  GlobalShortcut { name: "overviewEmojiToggle"; description: "Emoji"; onPressed: State.toggleSearch("emoji") }
  GlobalShortcut { name: "sidebarLeftToggle"; description: "Left sidebar"; onPressed: State.toggle("leftOpen") }
  GlobalShortcut { name: "sidebarRightToggle"; description: "Right sidebar"; onPressed: State.toggle("rightOpen") }
  GlobalShortcut { name: "mediaControlsToggle"; description: "Media controls"; onPressed: State.toggle("mediaOpen") }
  GlobalShortcut { name: "sessionToggle"; description: "Session menu"; onPressed: State.toggle("sessionOpen") }
  GlobalShortcut { name: "cheatsheetToggle"; description: "Cheatsheet"; onPressed: State.toggle("cheatsheetOpen") }
  GlobalShortcut { name: "barToggle"; description: "Toggle bar"; onPressed: State.barVisible = !State.barVisible }
  GlobalShortcut { name: "wallpaperSelectorToggle"; description: "Wallpaper selector"; onPressed: State.toggle("wallpaperOpen") }

  Process {
    id: randomWallpaper
    command: ["sh", "-c", "find \"$HOME/Pictures/Wallpapers\" -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\) 2>/dev/null | shuf -n1"]
    stdout: StdioCollector { onStreamFinished: { const f = text.trim(); if (f) State.setWallpaper(f) } }
  }
  GlobalShortcut {
    name: "wallpaperSelectorRandom"; description: "Random wallpaper"
    onPressed: randomWallpaper.running = true
  }

  GlobalShortcut {
    name: "regionScreenshot"; description: "Screenshot a region to the clipboard"
    onPressed: Quickshell.execDetached(["sh", "-c", "pidof slurp || hyprshot --freeze --clipboard-only --mode region --silent"])
  }
  GlobalShortcut {
    name: "regionOcr"; description: "OCR a region to the clipboard"
    onPressed: Quickshell.execDetached([hypr + "ocr.sh"])
  }
  GlobalShortcut {
    name: "regionRecord"; description: "Record a region (toggle)"
    onPressed: Quickshell.execDetached([hypr + "record.sh"])
  }

  IpcHandler {
    target: "TEST_ALIVE"
    function ping(): string { return "alive" }
  }
  IpcHandler {
    target: "brightness"
    function increment(): void { Sys.setBrightness(Math.min(100, Sys.brightness + 5)) }
    function decrement(): void { Sys.setBrightness(Math.max(1, Sys.brightness - 5)) }
  }
}
