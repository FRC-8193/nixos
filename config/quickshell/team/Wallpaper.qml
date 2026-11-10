import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
  Process {
    running: true
    command: ["sh", "-c", "cat \"$HOME/.local/state/team-shell/wallpaper\" 2>/dev/null"]
    stdout: StdioCollector { onStreamFinished: { const p = text.trim(); if (p) State.wallpaper = p } }
  }

  Variants {
    model: Quickshell.screens
    PanelWindow {
      required property var modelData
      screen: modelData
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Background
      WlrLayershell.namespace: "team-wallpaper"
      color: "#16161e"
      Image {
        anchors.fill: parent
        source: State.wallpaper ? "file://" + State.wallpaper : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
      }
    }
  }
}
