import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// Workspace overview: one card per workspace listing its windows. Click to jump.
PanelWindow {
  visible: State.overviewOpen
  anchors { top: true; bottom: true; left: true; right: true }
  color: "#99000000"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "team-overview"
  WlrLayershell.keyboardFocus: State.overviewOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  function windowsOn(ws) {
    const out = []
    const vals = Hyprland.toplevels.values
    for (let k = 0; k < vals.length; k++) {
      const t = vals[k]
      if (t.workspace && t.workspace.id === ws) out.push(t.title)
    }
    return out
  }

  MouseArea { anchors.fill: parent; onClicked: State.closeAll() }
  Item {
    anchors.fill: parent
    focus: true
    Keys.onEscapePressed: State.closeAll()
    onVisibleChanged: if (visible) forceActiveFocus()

    Grid {
      anchors.centerIn: parent
      columns: 5
      spacing: 14
      Repeater {
        model: 10
        delegate: Rectangle {
          required property int index
          readonly property int wsId: index + 1
          readonly property bool current: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
          width: 280; height: 180; radius: Theme.radius
          color: Theme.surface
          border.width: current ? 2 : 1
          border.color: current ? Theme.accent : Theme.surfaceHi
          Column {
            anchors { fill: parent; margins: 12 }
            spacing: 4
            Text { text: "Workspace " + wsId; color: Theme.accent; font.family: Theme.font; font.pixelSize: 15; font.bold: true }
            Repeater {
              model: windowsOn(wsId).slice(0, 6)
              delegate: Text {
                required property string modelData
                width: parent.width; elide: Text.ElideRight
                text: modelData; color: Theme.fg; font.family: Theme.font; font.pixelSize: 13
              }
            }
          }
          MouseArea { anchors.fill: parent; onClicked: { State.focusWorkspace(wsId); State.closeAll() } }
        }
      }
    }
  }
}
