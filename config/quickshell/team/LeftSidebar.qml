import QtQuick
import Quickshell
import Quickshell.Wayland

// Left sidebar: live system stats (handy when a robot laptop is struggling).
PanelWindow {
  visible: State.leftOpen
  anchors { top: true; bottom: true; left: true }
  margins { top: 48; bottom: 12; left: 12 }
  implicitWidth: 340
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "team-left"

  Rectangle {
    anchors.fill: parent
    radius: Theme.radius
    color: Theme.surface
    border.color: Theme.surfaceHi

    Column {
      anchors { fill: parent; margins: 18 }
      spacing: 14
      Text { text: "System"; color: Theme.accent; font.family: Theme.font; font.pixelSize: 20; font.bold: true }
      Repeater {
        model: [
          ["Load (1 min)", Sys.load],
          ["Memory", Sys.memUsed + " / " + Sys.memTotal + " MB"],
          ["Disk /", Sys.disk],
          ["Network", Sys.network],
          ["Power profile", Sys.powerProfile || "n/a"]
        ]
        delegate: Row {
          required property var modelData
          width: parent.width
          Text { width: parent.width * 0.45; text: modelData[0]; color: Theme.dim; font.family: Theme.font; font.pixelSize: 14 }
          Text { width: parent.width * 0.55; text: modelData[1]; color: Theme.fg; font.family: Theme.font; font.pixelSize: 14; elide: Text.ElideRight }
        }
      }
      Text { text: "Top processes (CPU %)"; color: Theme.accent; font.family: Theme.font; font.pixelSize: 15; topPadding: 6 }
      Repeater {
        model: Sys.topProcs
        delegate: Row {
          required property var modelData
          width: parent.width
          Text { width: parent.width * 0.7; text: modelData.name; color: Theme.fg; font.family: Theme.mono; font.pixelSize: 13; elide: Text.ElideRight }
          Text { width: parent.width * 0.3; text: modelData.cpu; color: Theme.dim; font.family: Theme.mono; font.pixelSize: 13; horizontalAlignment: Text.AlignRight }
        }
      }
    }
  }
}
