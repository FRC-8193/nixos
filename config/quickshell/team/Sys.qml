pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Polls a few system numbers every few seconds for the bar and sidebars.
Singleton {
  id: root

  property string load: "-"
  property string memUsed: "-"
  property string memTotal: "-"
  property string disk: "-"
  property string network: "offline"   // connection name, or "offline"
  property string netType: ""          // wifi | ethernet | ""
  property int brightness: 50          // percent
  property string powerProfile: ""
  property var topProcs: []

  Timer {
    interval: 5000; running: true; repeat: true; triggeredOnStart: true
    onTriggered: { stats.running = true; net.running = true; bright.running = true; prof.running = true; procs.running = true }
  }

  Process {
    id: stats
    command: ["sh", "-c", "read l _ < /proc/loadavg; echo \"$l $(free -m | awk '/Mem:/{print $3, $2}') $(df -h / | awk 'NR==2{print $3\"/\"$2}')\""]
    stdout: StdioCollector {
      onStreamFinished: {
        const p = text.trim().split(" ")
        if (p.length >= 4) { root.load = p[0]; root.memUsed = p[1]; root.memTotal = p[2]; root.disk = p[3] }
      }
    }
  }
  Process {
    id: net
    command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION device | grep ':connected:' | grep -v '^loopback' | head -1"]
    stdout: StdioCollector {
      onStreamFinished: {
        const l = text.trim()
        if (!l) { root.network = "offline"; root.netType = ""; return }
        const p = l.split(":")
        root.netType = p[0]
        root.network = p.slice(2).join(":") || p[0]
      }
    }
  }
  Process {
    id: bright
    command: ["sh", "-c", "brightnessctl -m 2>/dev/null | head -1 | cut -d, -f4 | tr -d '%'"]
    stdout: StdioCollector { onStreamFinished: { const v = parseInt(text.trim()); if (!isNaN(v)) root.brightness = v } }
  }
  Process {
    id: prof
    command: ["sh", "-c", "powerprofilesctl get 2>/dev/null"]
    stdout: StdioCollector { onStreamFinished: root.powerProfile = text.trim() }
  }
  Process {
    id: procs
    command: ["sh", "-c", "ps -eo comm,%cpu --sort=-%cpu --no-headers | head -6"]
    stdout: StdioCollector {
      onStreamFinished: root.topProcs = text.trim().split("\n").filter(l => l.length).map(l => {
        const m = l.trim().split(/\s+/)
        return { name: m[0], cpu: m[1] }
      })
    }
  }

  function setBrightness(percent) {
    brightness = percent
    Quickshell.execDetached(["brightnessctl", "set", percent + "%"])
  }
  function cyclePowerProfile() {
    Quickshell.execDetached(["sh", "-c",
      "p=$(powerprofilesctl get); case $p in power-saver) n=balanced;; balanced) n=performance;; *) n=power-saver;; esac; powerprofilesctl set $n"])
    prof.running = true
  }
  function toggleWifi() {
    Quickshell.execDetached(["sh", "-c", "nmcli radio wifi | grep -q enabled && nmcli radio wifi off || nmcli radio wifi on"])
  }
  function toggleBluetooth() { Quickshell.execDetached(["rfkill", "toggle", "bluetooth"]) }
}
