pragma Singleton
import QtQuick
import Quickshell

Singleton {
  readonly property color bg: "#ee16161e"
  readonly property color surface: "#f01a1b26"
  readonly property color surfaceHi: "#ff2a2e45"
  readonly property color fg: "#c0caf5"
  readonly property color dim: "#7a82a8"
  readonly property color accent: "#7aa2f7"
  readonly property color _onAccent: "#16161e"
  readonly property color danger: "#f7768e"
  readonly property color ok: "#9ece6a"
  readonly property int radius: 14
  readonly property string font: "Rubik"
  readonly property string mono: "JetBrainsMono Nerd Font"

  // Nerd Font (Material Design) glyphs
  function glyph(cp) { return String.fromCodePoint(cp) }
  readonly property string iVolume: glyph(0xF057E)
  readonly property string iMuted: glyph(0xF0581)
  readonly property string iWifi: glyph(0xF05A9)
  readonly property string iWifiOff: glyph(0xF05AA)
  readonly property string iBattery: glyph(0xF0079)
  readonly property string iBluetooth: glyph(0xF00AF)
  readonly property string iBright: glyph(0xF00DF)
  readonly property string iPower: glyph(0xF0425)
  readonly property string iLock: glyph(0xF033E)
  readonly property string iLogout: glyph(0xF0343)
  readonly property string iSleep: glyph(0xF04B2)
  readonly property string iReboot: glyph(0xF0709)
  readonly property string iBell: glyph(0xF009C)
  readonly property string iBellOff: glyph(0xF009B)
  readonly property string iPlay: glyph(0xF040A)
  readonly property string iPause: glyph(0xF03E4)
  readonly property string iNext: glyph(0xF04AD)
  readonly property string iPrev: glyph(0xF04AE)
  readonly property string iCpu: glyph(0xF0EE0)
  readonly property string iClose: glyph(0xF0156)
}
