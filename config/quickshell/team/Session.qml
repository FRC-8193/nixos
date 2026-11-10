import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
  visible: State.sessionOpen
  anchors { top: true; bottom: true; left: true; right: true }
  color: "#aa000000"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "team-session"
  WlrLayershell.keyboardFocus: State.sessionOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  MouseArea { anchors.fill: parent; onClicked: State.closeAll() }
  Item {
    anchors.fill: parent
    focus: true
    Keys.onEscapePressed: State.closeAll()
    onVisibleChanged: if (visible) forceActiveFocus()

    Row {
      anchors.centerIn: parent
      spacing: 18
      Repeater {
        model: [
          { label: "Lock", icon: Theme.iLock, cmd: "loginctl lock-session" },
          { label: "Log out", icon: Theme.iLogout, cmd: "loginctl terminate-user $USER" },
          { label: "Sleep", icon: Theme.iSleep, cmd: "systemctl suspend" },
          { label: "Restart", icon: Theme.iReboot, cmd: "systemctl reboot" },
          { label: "Shut down", icon: Theme.iPower, cmd: "systemctl poweroff" }
        ]
        delegate: Rectangle {
          required property var modelData
          width: 130; height: 130; radius: Theme.radius
          color: hover.containsMouse ? Theme.accent : Theme.surface
          Column {
            anchors.centerIn: parent
            spacing: 8
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.icon; font.family: Theme.mono; font.pixelSize: 40; color: hover.containsMouse ? Theme.onAccent : Theme.fg }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.label; font.family: Theme.font; font.pixelSize: 14; color: hover.containsMouse ? Theme.onAccent : Theme.fg }
          }
          MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            onClicked: { State.closeAll(); Quickshell.execDetached(["sh", "-c", modelData.cmd]) }
          }
        }
      }
    }
  }
}
