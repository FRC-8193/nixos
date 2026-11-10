import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Wayland

PanelWindow {
  id: win
  visible: State.mediaOpen
  anchors { top: true }
  margins { top: 48 }
  implicitWidth: 420
  implicitHeight: 120
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "team-media"

  readonly property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

  Rectangle {
    anchors.fill: parent
    radius: Theme.radius
    color: Theme.surface
    border.color: Theme.surfaceHi

    Text {
      visible: !win.player
      anchors.centerIn: parent
      text: "Nothing playing"
      color: Theme.dim; font.family: Theme.font; font.pixelSize: 15
    }

    Row {
      visible: !!win.player
      anchors { fill: parent; margins: 14 }
      spacing: 14
      Image {
        width: 92; height: 92
        source: win.player ? win.player.trackArtUrl : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
      }
      Column {
        width: parent.width - 106
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4
        Text { width: parent.width; elide: Text.ElideRight; text: win.player ? win.player.trackTitle : ""; color: Theme.fg; font.family: Theme.font; font.pixelSize: 16; font.bold: true }
        Text { width: parent.width; elide: Text.ElideRight; text: win.player ? win.player.trackArtist : ""; color: Theme.dim; font.family: Theme.font; font.pixelSize: 13 }
        Row {
          spacing: 6
          Pill { text: Theme.iPrev; fontFamily: Theme.mono; onClicked: if (win.player) win.player.previous() }
          Pill { text: win.player && win.player.isPlaying ? Theme.iPause : Theme.iPlay; fontFamily: Theme.mono; active: true; onClicked: if (win.player) win.player.togglePlaying() }
          Pill { text: Theme.iNext; fontFamily: Theme.mono; onClicked: if (win.player) win.player.next() }
        }
      }
    }
  }
}
