import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Wayland

// Picks from ~/Pictures/Wallpapers. Put images there.
PanelWindow {
  id: win
  visible: State.wallpaperOpen
  anchors { top: true; bottom: true; left: true; right: true }
  color: "#99000000"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "team-wallpapers"
  WlrLayershell.keyboardFocus: State.wallpaperOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  FolderListModel {
    id: files
    folder: "file://" + Quickshell.env("HOME") + "/Pictures/Wallpapers"
    nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
    showDirs: false
    sortField: FolderListModel.Name
  }

  MouseArea { anchors.fill: parent; onClicked: State.closeAll() }
  Item {
    anchors.fill: parent
    focus: true
    Keys.onEscapePressed: State.closeAll()
    onVisibleChanged: if (visible) forceActiveFocus()

    Rectangle {
      anchors.centerIn: parent
      width: Math.min(parent.width - 120, 1100)
      height: Math.min(parent.height - 160, 640)
      radius: Theme.radius + 4
      color: Theme.surface
      border.color: Theme.surfaceHi

      Text {
        visible: files.count === 0
        anchors.centerIn: parent
        text: "No images found in ~/Pictures/Wallpapers"
        color: Theme.dim; font.family: Theme.font; font.pixelSize: 16
      }
      GridView {
        anchors { fill: parent; margins: 16 }
        cellWidth: 260; cellHeight: 160
        clip: true
        model: files
        delegate: Item {
          required property string filePath
          required property string fileName
          width: 250; height: 150
          Image {
            anchors.fill: parent
            source: "file://" + filePath
            sourceSize: Qt.size(500, 300)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
          }
          Rectangle {
            anchors.fill: parent; color: "transparent"; radius: 8
            border.width: filePath === State.wallpaper ? 3 : 0
            border.color: Theme.accent
          }
          MouseArea { anchors.fill: parent; onClicked: State.setWallpaper(filePath) }
        }
      }
    }
  }
}
