import QtQuick
import Quickshell
import Quickshell.Wayland

// Invisible full-screen layer under the side panels: click anywhere to close them.
PanelWindow {
  visible: State.sidePanelOpen
  anchors { top: true; bottom: true; left: true; right: true }
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.namespace: "team-backdrop"
  MouseArea { anchors.fill: parent; onClicked: State.closeAll() }
}
