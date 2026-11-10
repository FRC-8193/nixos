import QtQuick

// Small clickable label used all over the bar.
Rectangle {
  id: pill
  property alias text: label.text
  property color textColor: Theme.fg
  property bool active: false
  property string fontFamily: Theme.font
  signal clicked()
  signal scrolled(int delta)

  implicitWidth: label.implicitWidth + 20
  implicitHeight: 28
  radius: 10
  color: active ? Theme.accent : (mouse.containsMouse ? Theme.surfaceHi : "transparent")

  Text {
    id: label
    anchors.centerIn: parent
    color: pill.active ? Theme.onAccent : pill.textColor
    font.family: pill.fontFamily
    font.pixelSize: 14
  }
  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    onClicked: pill.clicked()
    onWheel: wheel => pill.scrolled(wheel.angleDelta.y)
  }
}
