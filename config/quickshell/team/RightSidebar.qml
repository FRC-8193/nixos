import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Wayland

// Right sidebar: quick settings (volume, brightness, toggles) + notification history.
PanelWindow {
  id: win
  visible: State.rightOpen
  anchors { top: true; bottom: true; right: true }
  margins { top: 48; bottom: 12; right: 12 }
  implicitWidth: 400
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "team-right"

  property var sink: Pipewire.defaultAudioSink
  PwObjectTracker { objects: [win.sink] }

  Rectangle {
    anchors.fill: parent
    radius: Theme.radius
    color: Theme.surface
    border.color: Theme.surfaceHi

    Column {
      id: top
      anchors { top: parent.top; left: parent.left; right: parent.right; margins: 18 }
      spacing: 14

      SystemClock { id: clk; precision: SystemClock.Minutes }
      Text {
        text: Qt.formatDateTime(clk.date, "HH:mm")
        color: Theme.fg; font.family: Theme.font; font.pixelSize: 40; font.bold: true
      }
      Text { text: Qt.formatDateTime(clk.date, "dddd, d MMMM yyyy"); color: Theme.dim; font.family: Theme.font; font.pixelSize: 14 }

      Row {
        spacing: 10
        Text { width: 24; text: Theme.iVolume; color: Theme.accent; font.family: Theme.mono; font.pixelSize: 18 }
        QsSlider {
          width: top.width - 34
          value: win.sink && win.sink.audio ? win.sink.audio.volume : 0
          onMoved: v => { if (win.sink && win.sink.audio) win.sink.audio.volume = v }
        }
      }
      Row {
        spacing: 10
        Text { width: 24; text: Theme.iBright; color: Theme.accent; font.family: Theme.mono; font.pixelSize: 18 }
        QsSlider {
          width: top.width - 34
          value: Sys.brightness / 100
          onMoved: v => Sys.setBrightness(Math.max(1, Math.round(v * 100)))
        }
      }

      Flow {
        width: parent.width
        spacing: 8
        Pill { text: Theme.iWifi + " Wi-Fi"; fontFamily: Theme.mono; onClicked: Sys.toggleWifi() }
        Pill { text: Theme.iBluetooth + " Bluetooth"; fontFamily: Theme.mono; onClicked: Sys.toggleBluetooth() }
        Pill { text: Theme.iCpu + " " + (Sys.powerProfile || "profile"); fontFamily: Theme.mono; onClicked: Sys.cyclePowerProfile() }
        Pill {
          text: (Notifs.dnd ? Theme.iBellOff : Theme.iBell) + " Do not disturb"
          fontFamily: Theme.mono
          active: Notifs.dnd
          onClicked: Notifs.dnd = !Notifs.dnd
        }
      }

      Row {
        width: parent.width
        Text { width: parent.width - clear.width; text: "Notifications"; color: Theme.accent; font.family: Theme.font; font.pixelSize: 16; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
        Pill { id: clear; text: "Clear"; onClicked: Notifs.clearAll() }
      }
    }

    ListView {
      anchors { top: top.bottom; topMargin: 8; left: parent.left; right: parent.right; bottom: parent.bottom; margins: 18 }
      clip: true
      spacing: 8
      model: Notifs.history
      delegate: Rectangle {
        required property string app
        required property string summary
        required property string body
        width: ListView.view.width
        height: col.implicitHeight + 20
        radius: 10
        color: Theme.surfaceHi
        Column {
          id: col
          anchors { fill: parent; margins: 10 }
          spacing: 2
          Text { text: app; color: Theme.dim; font.family: Theme.font; font.pixelSize: 11 }
          Text { width: parent.width; text: summary; color: Theme.fg; font.family: Theme.font; font.pixelSize: 14; font.bold: true; wrapMode: Text.Wrap }
          Text { width: parent.width; visible: body.length > 0; text: body; color: Theme.fg; font.family: Theme.font; font.pixelSize: 13; wrapMode: Text.Wrap; maximumLineCount: 4; elide: Text.ElideRight }
        }
      }
    }
  }
}
