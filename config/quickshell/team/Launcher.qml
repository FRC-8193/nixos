import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Search / launcher. Modes: apps (default), clipboard history, emoji.
// In apps mode, start the query with ">" to run a shell command.
PanelWindow {
  id: win
  visible: State.searchOpen
  anchors { top: true; bottom: true; left: true; right: true }
  color: "#66000000"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "team-launcher"
  WlrLayershell.keyboardFocus: State.searchOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  property int sel: 0
  property var clipLines: []
  readonly property var emojis: [
    ["😀", "grin smile happy"], ["😂", "joy laugh"], ["🙂", "slight smile"], ["😉", "wink"], ["😍", "heart eyes love"],
    ["🤔", "thinking"], ["😅", "sweat smile"], ["😭", "cry sad"], ["😎", "cool sunglasses"], ["🙃", "upside down"],
    ["😴", "sleep tired"], ["🤯", "mind blown"], ["😱", "scream shock"], ["😡", "angry"], ["🥳", "party celebrate"],
    ["👍", "thumbs up yes ok"], ["👎", "thumbs down no"], ["👏", "clap applause"], ["🙏", "pray thanks please"], ["💪", "muscle strong"],
    ["👀", "eyes look"], ["🔥", "fire hot"], ["✨", "sparkles"], ["🎉", "tada party"], ["❤️", "heart red love"],
    ["💔", "broken heart"], ["⭐", "star"], ["✅", "check done yes"], ["❌", "cross no wrong"], ["⚠️", "warning"],
    ["❓", "question"], ["❗", "exclamation"], ["💡", "idea bulb"], ["🚀", "rocket launch"], ["🤖", "robot"],
    ["⚙️", "gear settings"], ["🔧", "wrench tool"], ["🔩", "bolt nut"], ["🔋", "battery"], ["🔌", "plug power"],
    ["📡", "antenna radio"], ["🛠️", "tools"], ["💻", "laptop computer"], ["🖥️", "desktop computer"], ["⌨️", "keyboard"],
    ["🖨️", "printer"], ["📷", "camera"], ["📹", "video camera"], ["🔍", "search magnifier"], ["🔒", "lock"],
    ["🔓", "unlock"], ["📌", "pin"], ["📎", "paperclip"], ["📝", "memo note"], ["📅", "calendar"],
    ["⏰", "alarm clock time"], ["🏆", "trophy win"], ["🥇", "gold medal first"], ["🎯", "target goal"], ["🐛", "bug"],
    ["🧪", "test tube experiment"], ["📈", "chart up"], ["📉", "chart down"], ["➡️", "arrow right"], ["⬅️", "arrow left"],
    ["⬆️", "arrow up"], ["⬇️", "arrow down"], ["☕", "coffee"], ["🍕", "pizza"], ["🎶", "music notes"]
  ]

  function results(q, mode, clip) {
    const t = q.toLowerCase()
    if (mode === "clipboard") {
      return clip.filter(l => l.toLowerCase().includes(t)).slice(0, 40).map(l => ({
        kind: "clip", title: l.substring(l.indexOf("\t") + 1), subtitle: "", id: l.split("\t")[0] }))
    }
    if (mode === "emoji") {
      return emojis.filter(e => e[1].includes(t)).slice(0, 60).map(e => ({
        kind: "emoji", title: e[0] + "   " + e[1], subtitle: "", emoji: e[0] }))
    }
    if (q.startsWith(">")) return [{ kind: "cmd", title: "Run: " + q.substring(1).trim(), subtitle: "", cmd: q.substring(1).trim() }]
    const apps = DesktopEntries.applications.values.filter(e => !e.noDisplay && e.name.toLowerCase().includes(t))
    apps.sort((a, b) => a.name.localeCompare(b.name))
    return apps.slice(0, 8).map(e => ({ kind: "app", title: e.name, subtitle: e.comment || "", icon: e.icon, entry: e }))
  }

  property var items: results(input.text, State.searchMode, clipLines)
  onItemsChanged: sel = 0

  function activate(it) {
    if (!it) return
    if (it.kind === "app") it.entry.execute()
    else if (it.kind === "cmd") Quickshell.execDetached(["sh", "-c", it.cmd])
    else if (it.kind === "clip")
      Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy", "_", it.id])
    else if (it.kind === "emoji")
      Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | wl-copy", "_", it.emoji])
    State.closeAll()
  }

  onVisibleChanged: {
    if (!visible) return
    input.text = ""
    sel = 0
    input.forceActiveFocus()
    if (State.searchMode === "clipboard") clipProc.running = true
  }

  Process {
    id: clipProc
    command: ["cliphist", "list"]
    stdout: StdioCollector { onStreamFinished: win.clipLines = text.split("\n").filter(l => l.length) }
  }

  MouseArea { anchors.fill: parent; onClicked: State.closeAll() }

  Rectangle {
    anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: parent.height * 0.18 }
    width: 600
    height: header.height + list.contentHeight + 28
    radius: Theme.radius + 4
    color: Theme.surface
    border.color: Theme.surfaceHi
    border.width: 1

    Column {
      anchors { fill: parent; margins: 14 }
      spacing: 8

      Rectangle {
        id: header
        width: parent.width; height: 44; radius: 10
        color: Theme.surfaceHi
        TextInput {
          id: input
          anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
          verticalAlignment: TextInput.AlignVCenter
          color: Theme.fg
          font.family: Theme.font
          font.pixelSize: 17
          selectionColor: Theme.accent
          clip: true
          Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) { State.closeAll(); event.accepted = true }
            else if (event.key === Qt.Key_Down) { win.sel = Math.min(win.sel + 1, win.items.length - 1); event.accepted = true }
            else if (event.key === Qt.Key_Up) { win.sel = Math.max(win.sel - 1, 0); event.accepted = true }
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { win.activate(win.items[win.sel]); event.accepted = true }
          }
          Text {
            visible: input.text.length === 0
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.dim
            font: input.font
            text: State.searchMode === "clipboard" ? "Clipboard history..." : (State.searchMode === "emoji" ? "Search emoji..." : "Search apps, or > to run a command")
          }
        }
      }

      ListView {
        id: list
        width: parent.width
        height: contentHeight
        interactive: false
        model: win.items
        delegate: Rectangle {
          required property var modelData
          required property int index
          width: list.width; height: 44; radius: 10
          color: index === win.sel ? Theme.surfaceHi : "transparent"
          Row {
            anchors { fill: parent; leftMargin: 10 }
            spacing: 10
            Image {
              visible: modelData.kind === "app"
              anchors.verticalCenter: parent.verticalCenter
              width: 28; height: 28
              source: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : ""
              sourceSize: Qt.size(56, 56)
            }
            Text {
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - 60
              elide: Text.ElideRight
              text: modelData.title + (modelData.subtitle ? "   " + modelData.subtitle : "")
              color: Theme.fg
              font.family: Theme.font
              font.pixelSize: 15
            }
          }
          MouseArea { anchors.fill: parent; hoverEnabled: true; onEntered: win.sel = index; onClicked: win.activate(modelData) }
        }
      }
    }
  }
}
