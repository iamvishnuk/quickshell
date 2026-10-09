import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

RowLayout {
  id: root

  Layout.preferredWidth: 100
  Layout.preferredHeight: 30

  property real cpuUsage: 0
  property real memoryUsage: 0

  property real previousIdle: 0
  property real previousTotal: 0

  Timer {
    interval: 2000
    running: true
    repeat: true

    onTriggered: {
      cpuProcess.running = true
      memoryProcess.running = true
    }
  }

  Process {
    id: cpuProcess

    command: ["sh", "-c", "head -n 1 /proc/stat"]

    stdout: StdioCollector {
      onStreamFinished: {
        const parts = text.trim().split(/\s+/)

        if (parts.length < 5) return

        const user = Number(parts[1])
        const nice = Number(parts[2])
        const system = Number(parts[3])
        const idle = Number(parts[4])
        const iowait = Number(parts[5] || 0)
        const irq = Number(parts[6] || 0)
        const softirq = Number(parts[7] || 0)
        const steal = Number(parts[8] || 0)

        const idleTime = idle + iowait

        const total =
          user +
          nice +
          system +
          idle +
          iowait +
          irq +
          softirq +
          steal

        if (root.previousTotal > 0) {
          const totalDelta =
            total - root.previousTotal

          const idleDelta =
            idleTime - root.previousIdle

          if (totalDelta > 0) {
            root.cpuUsage =
              (1 - idleDelta / totalDelta) * 100
          }
        }

        root.previousIdle = idleTime
        root.previousTotal = total
      }
    }
  }

  Process {
    id: memoryProcess

    command: [
      "sh",
      "-c",
      "awk '/MemTotal:/ {total=$2} /MemAvailable:/ {available=$2} END {printf \"%d %d\\n\", total, available}' /proc/meminfo"
    ]

    stdout: StdioCollector {
      onStreamFinished: {
        const parts = text.trim().split(/\s+/)

        if (parts.length < 2)
          return

        const total = Number(parts[0])
        const available = Number(parts[1])

        if (total <= 0)
          return

        root.memoryUsage =
          ((total - available) / total) * 100
      }
    }
  }

  Process {
    id: openHtopProcess
    command: [ "ghostty", "--title=htop", "-e", "htop"]
  }

  Process {
    id: openBtopProcess
    command: ["ghostty", "--title=btop", "-e", "btop"]
  }

  Rectangle {
    Layout.preferredWidth: 50
    Layout.preferredHeight: 30
    color: "transparent"

    RowLayout {
      anchors.centerIn: parent
      spacing: 3

      Text {
        text: " " 
        color: "white"
        font {
          family: "JetBrainsMono Nerd Font"
          pixelSize: 14
        }
      }

      Text {
        text: Math.round(root.cpuUsage) + "%"
        color: "white"
        font {
          family: "Inter"
          pixelSize: 11
        }
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
          openBtopProcess.running = true
        }
      }
    }
  }

  Rectangle {
    Layout.preferredWidth: 50
    Layout.preferredHeight: 30
    color: "transparent"

    RowLayout {
      anchors.centerIn: parent
      spacing: 3
      Text {
        text: " "
        color: "white"
        font {
          family: "JetBrainsMono Nerd Font"
          pixelSize: 14
        }
      }

      Text {
        text: Math.round(root.memoryUsage) + "%"
        color: "white"
        font {
          family: "Inter"
          pixelSize: 11
        }
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
          openHtopProcess.running = true
        }
      }
    }

  }

  Component.onCompleted: {
    cpuProcess.running = true
    memoryProcess.running = true
  }
}
