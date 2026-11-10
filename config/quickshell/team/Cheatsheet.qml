import QtQuick
import Quickshell
import Quickshell.Wayland

// Keybind reference. Keep in sync with config/hypr/keybinds.lua.
PanelWindow {
  visible: State.cheatsheetOpen
  anchors { top: true; bottom: true; left: true; right: true }
  color: "#99000000"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "team-cheatsheet"
  WlrLayershell.keyboardFocus: State.cheatsheetOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  readonly property var sections: [
    { title: "Shell", rows: [
      ["Super (tap)", "Search / launcher"], ["Super+Tab", "Overview"], ["Super+V", "Clipboard history"],
      ["Super+.", "Emoji"], ["Super+A", "System sidebar"], ["Super+N", "Quick settings"],
      ["Super+M", "Media"], ["Super+J", "Toggle bar"], ["Ctrl+Alt+Del", "Session menu"],
      ["Ctrl+Super+T", "Wallpapers"], ["Super+/", "This sheet"] ] },
    { title: "Windows", rows: [
      ["Super+Arrows", "Focus"], ["Super+Shift+Arrows", "Move"], ["Super+W", "Close"],
      ["Super+F", "Fullscreen"], ["Super+D", "Maximize"], ["Super+Alt+Space", "Float / tile"],
      ["Super+P", "Pin"], ["Super+Drag", "Move / resize (left / right button)"] ] },
    { title: "Workspaces", rows: [
      ["Super+1..0", "Go to workspace"], ["Super+Shift+1..0", "Move window there"],
      ["Super+S", "Scratchpad"], ["Super+Alt+S", "Send to scratchpad"],
      ["Ctrl+Super+Left/Right", "Previous / next"] ] },
    { title: "Tools", rows: [
      ["Super+Return", "Terminal"], ["Super+E", "Files"], ["Super+C", "Code editor"],
      ["Super+Shift+S", "Screenshot region"], ["Super+Shift+X", "OCR region"],
      ["Super+Shift+C", "Color picker"], ["Super+Shift+R", "Record region"],
      ["Super+L", "Lock"], ["Ctrl+Shift+Esc", "Task manager"] ] }
  ]

  MouseArea { anchors.fill: parent; onClicked: State.closeAll() }
  Item {
    anchors.fill: parent
    focus: true
    Keys.onEscapePressed: State.closeAll()
    onVisibleChanged: if (visible) forceActiveFocus()

    Rectangle {
      anchors.centerIn: parent
      width: grid.implicitWidth + 48; height: grid.implicitHeight + 48
      radius: Theme.radius + 4
      color: Theme.surface
      border.color: Theme.surfaceHi
      Grid {
        id: grid
        anchors.centerIn: parent
        columns: 2
        spacing: 28
        Repeater {
          model: sections
          delegate: Column {
            required property var modelData
            spacing: 5
            Text { text: modelData.title; color: Theme.accent; font.family: Theme.font; font.pixelSize: 16; font.bold: true; bottomPadding: 4 }
            Repeater {
              model: modelData.rows
              delegate: Row {
                required property var modelData
                spacing: 12
                Text { width: 190; text: modelData[0]; color: Theme.fg; font.family: Theme.mono; font.pixelSize: 13 }
                Text { width: 240; text: modelData[1]; color: Theme.dim; font.family: Theme.font; font.pixelSize: 13 }
              }
            }
          }
        }
      }
    }
  }
}
