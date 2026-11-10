//@ pragma UseQApplication
import QtQuick
import Quickshell

// Team desktop shell. Start with `qs -c team` (Hyprland does this on login).
ShellRoot {
  Wallpaper {}

  Variants {
    model: Quickshell.screens
    Bar {
      required property var modelData
      screen: modelData
    }
  }

  Backdrop {}
  Launcher {}
  Overview {}
  LeftSidebar {}
  RightSidebar {}
  MediaControls {}
  Session {}
  Cheatsheet {}
  WallpaperSelector {}
  NotificationPopups {}
  Shortcuts {}
}
