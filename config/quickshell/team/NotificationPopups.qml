import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
  visible: Notifs.popups.count > 0
  anchors { top: true; right: true }
  margins { top: 48; right: 12 }
  implicitWidth: 360
  implicitHeight: stack.implicitHeight
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "team-notifications"

  Column {
    id: stack
    width: parent.width
    spacing: 8
    Repeater {
      model: Notifs.popups
      delegate: Rectangle {
        required property int nid
        required property string app
        required property string summary
        required property string body
        width: stack.width
        height: col.implicitHeight + 24
        radius: Theme.radius
        color: Theme.surface
        border.color: Theme.surfaceHi

        Timer { running: true; interval: 6000; onTriggered: Notifs.dismissPopup(nid) }
        MouseArea { anchors.fill: parent; onClicked: Notifs.dismissPopup(nid) }

        Column {
          id: col
          anchors { fill: parent; margins: 12 }
          spacing: 2
          Text { text: app; color: Theme.dim; font.family: Theme.font; font.pixelSize: 11 }
          Text { width: parent.width; text: summary; color: Theme.fg; font.family: Theme.font; font.pixelSize: 14; font.bold: true; wrapMode: Text.Wrap }
          Text { width: parent.width; visible: body.length > 0; text: body; color: Theme.fg; font.family: Theme.font; font.pixelSize: 13; wrapMode: Text.Wrap; maximumLineCount: 3; elide: Text.ElideRight }
        }
      }
    }
  }
}
