import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray

PanelWindow {
  id: bar
  visible: State.barVisible
  anchors { top: true; left: true; right: true }
  implicitHeight: 40
  color: "transparent"

  property var sink: Pipewire.defaultAudioSink
  PwObjectTracker { objects: [bar.sink] }

  function wsExists(i) {
    const vals = Hyprland.workspaces.values
    for (let k = 0; k < vals.length; k++) if (vals[k].id === i) return true
    return false
  }
  function volumeText() {
    if (!sink || !sink.audio) return Theme.iVolume + " --"
    return (sink.audio.muted ? Theme.iMuted : Theme.iVolume) + " " + Math.round(sink.audio.volume * 100) + "%"
  }
  function batteryPercent() {
    const p = UPower.displayDevice.percentage
    return Math.round(p <= 1 ? p * 100 : p)
  }

  Rectangle {
    anchors { fill: parent; margins: 4 }
    radius: Theme.radius
    color: Theme.bg

    // ---- left: workspaces + active window
    Row {
      anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
      spacing: 4
      Repeater {
        model: 10
        delegate: Pill {
          required property int index
          readonly property int wsId: index + 1
          visible: bar.wsExists(wsId) || (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId) || State.showWorkspaceNumbers
          text: String(wsId)
          fontFamily: Theme.mono
          active: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
          onClicked: State.focusWorkspace(wsId)
        }
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        leftPadding: 10
        width: Math.min(implicitWidth, 360)
        elide: Text.ElideRight
        text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
        color: Theme.dim
        font.family: Theme.font
        font.pixelSize: 13
      }
    }

    // ---- center: clock
    Pill {
      id: clock
      anchors.centerIn: parent
      SystemClock { id: clk; precision: SystemClock.Minutes }
      text: Qt.formatDateTime(clk.date, "ddd d MMM  HH:mm")
      onClicked: State.toggle("rightOpen")
    }

    // ---- right: tray, status, power
    Row {
      anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
      spacing: 4

      Repeater {
        model: SystemTray.items
        delegate: MouseArea {
          required property var modelData
          width: 24; height: 28
          acceptedButtons: Qt.LeftButton | Qt.RightButton
          onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) modelData.activate()
            else modelData.secondaryActivate()
          }
          Image {
            anchors.centerIn: parent
            width: 18; height: 18
            source: modelData.icon
            sourceSize: Qt.size(36, 36)
          }
        }
      }

      Pill {
        text: Sys.netType === "wifi" ? Theme.iWifi + " " + Sys.network : (Sys.netType === "" ? Theme.iWifiOff : Theme.glyph(0xF0200) + " " + Sys.network)
        fontFamily: Theme.mono
        onClicked: Quickshell.execDetached(["nm-connection-editor"])
      }
      Pill {
        text: bar.volumeText()
        fontFamily: Theme.mono
        onClicked: if (bar.sink && bar.sink.audio) bar.sink.audio.muted = !bar.sink.audio.muted
        onScrolled: d => {
          if (bar.sink && bar.sink.audio)
            bar.sink.audio.volume = Math.max(0, Math.min(1.0, bar.sink.audio.volume + (d > 0 ? 0.02 : -0.02)))
        }
      }
      Pill {
        visible: UPower.displayDevice.isLaptopBattery
        text: Theme.iBattery + " " + bar.batteryPercent() + "%"
        fontFamily: Theme.mono
        textColor: bar.batteryPercent() < 20 ? Theme.danger : Theme.fg
      }
      Pill {
        text: Notifs.dnd ? Theme.iBellOff : Theme.iBell
        fontFamily: Theme.mono
        onClicked: State.toggle("rightOpen")
      }
      Pill {
        text: Theme.iPower
        fontFamily: Theme.mono
        textColor: Theme.danger
        onClicked: State.toggle("sessionOpen")
      }
    }
  }
}
