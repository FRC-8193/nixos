import QtQuick

Item {
  id: s
  property real value: 0
  property color fill: Theme.accent
  signal moved(real v)
  implicitHeight: 24
  implicitWidth: 200

  Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    width: parent.width; height: 8; radius: 4
    color: Theme.surfaceHi
    Rectangle {
      width: parent.width * Math.max(0, Math.min(1, s.value))
      height: parent.height; radius: 4
      color: s.fill
    }
  }
  MouseArea {
    anchors.fill: parent
    function setFrom(x) { s.moved(Math.max(0, Math.min(1, x / width))) }
    onPressed: m => setFrom(m.x)
    onPositionChanged: m => { if (pressed) setFrom(m.x) }
  }
}
