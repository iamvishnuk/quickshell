import Quickshell
import Quickshell.Networking
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

RowLayout {
  id: root

  property var wifiDevice: Networking.devices.values.find( d => d.type === DeviceType.Wifi)

  property var active: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null

  readonly property bool connected:
    wifiDevice !== null &&
    wifiDevice !== undefined &&
    wifiDevice.connected

  readonly property real signal: active ? active.signalStrength : 0

  readonly property string interfaceName: wifiDevice ? wifiDevice.name : ""

  property real downloadSpeed: 0
  property real uploadSpeed: 0

  property var downloadHistory: []
  property var uploadHistory: []

  property real previousRx: -1
  property real previousTx: -1

  Layout.preferredHeight: 30
  Layout.preferredWidth: 20


  // =========================================================
  // WIFI ICON
  // =========================================================

  readonly property string icon: {
    if (!Networking.wifiEnabled) {
      return String.fromCodePoint(0xF05AA)
    }

    if (!root.connected) {
      return String.fromCodePoint(0xF092D)
    }

    const tier =
      signal >= 0.75 ? 4 :
      signal >= 0.50 ? 3 :
      signal >= 0.25 ? 2 :
      1

    return String.fromCodePoint( 0xF091F + (tier - 1) * 3)
  }


  Text {
    anchors.centerIn: parent
    id: wifiIcon
    text: root.icon
    color: Networking.wifiEnabled ? "white" : "red"
    font {
        family: "JetBrainsMono Nerd Font"
        pixelSize: 14
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: {
      networkPopup.visible = !networkPopup.visible

      if (networkPopup.visible) {
        root.updateNetworkStats()
      }
    }
  }

  // =========================================================
  // NETWORK STATISTICS
  // =========================================================

  Process {
    id: statsProcess

    command: [
      "sh",
      "-c",
      "cat /sys/class/net/" +
      root.interfaceName +
      "/statistics/rx_bytes; " +
      "cat /sys/class/net/" +
      root.interfaceName +
      "/statistics/tx_bytes"
    ]

    stdout: StdioCollector {
      onStreamFinished: {
        const lines = this.text .trim() .split("\n")
        if (lines.length < 2) {
          return
        }

        const rx = Number(lines[0])
        const tx = Number(lines[1])

        if (!Number.isFinite(rx) || !Number.isFinite(tx)) {
          return
        }

        // First reading establishes the baseline.
        if (root.previousRx < 0 || root.previousTx < 0) {
            root.previousRx = rx
            root.previousTx = tx
            return
        }

        const rxDiff = Math.max(0, rx - root.previousRx)
        const txDiff = Math.max(0, tx - root.previousTx)

        /*
         * Timer interval is 1000ms,
         * so byte difference ~= bytes/sec.
        */

        root.downloadSpeed = rxDiff
        root.uploadSpeed = txDiff

        root.previousRx = rx
        root.previousTx = tx

        // Add samples
        root.downloadHistory = root.downloadHistory.concat([rxDiff])

        root.uploadHistory = root.uploadHistory.concat([txDiff])

        // Keep last 40 samples
        if (root.downloadHistory.length > 40) {
          root.downloadHistory = root.downloadHistory.slice(-40)
        }

        if (root.uploadHistory.length > 40) {
          root.uploadHistory = root.uploadHistory.slice(-40)
        }

        networkGraph.requestPaint()
      }
    }
  }

  Process {
    id: wifiManageProcess
    command: ["nmrs"]
  }

  // =========================================================
  // SAMPLE EVERY SECOND
  // =========================================================

  Timer {
    id: speedTimer
    interval: 1000
    running: root.interfaceName !== ""
    repeat: true
    onTriggered: {
      root.updateNetworkStats()
    }
  }

    // =========================================================
    // POPUP
    // =========================================================

  PopupWindow {
    id: networkPopup
    anchor.item: wifiIcon
    anchor.rect.x: root.width / 2 - width / 2
    anchor.rect.y: root.height - 5
    width: 350
    height: 330
    color: "transparent"
    grabFocus: true

    Rectangle {
      anchors.fill: parent
      radius: 10
      color: "#151515"
      border {
        width: 1
        color: "#303030"
      }
      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // =================================================
        // HEADER
        // =================================================

        RowLayout {
          Layout.fillWidth: true
          spacing: 10

          Text {
            text: root.icon
            color: "white"
            font {
              family: "JetBrainsMono Nerd Font"
              pixelSize: 20
            }
          }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
              Layout.fillWidth: true
              text:
                root.connected && root.active
                ? root.active.name
                : "Wi-Fi disconnected"
              color: "white"
              font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 14
                bold: true
              }
              elide: Text.ElideRight
            }

            Text {
              text:
                root.connected
                ? "Connected"
                : Networking.wifiEnabled
                  ? "Not connected"
                  : "Wi-Fi disabled"

              color: root.connected ? "#7ddc9a" : "#888888"

              font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 10
              }
            }
          }


          Rectangle {
            width: 30
            height: 30
            color: "transparent"

            Text {
              anchors.centerIn: parent
              text: "󱚾 "
              color: "white"
              font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 16
              }
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor

              onClicked: {
                wifiManageProcess.running = true
                networkPopup.visible = false
              }
            }
          }
        }


        // =================================================
        // SPEED CARDS
        // =================================================

        RowLayout {
          Layout.fillWidth: true
          spacing: 8

          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            radius: 8
            color: "#1d1d1d"

            RowLayout {
              anchors.fill: parent
              anchors.margins: 10
              spacing: 8

              Text {
                text: "↓"
                color: "#75f1fa"
                font {
                  family: "JetBrainsMono Nerd Font"
                  pixelSize: 18
                }
              }


              ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                  text: "DOWNLOAD"
                  color: "#777777"
                  font {
                    family: "JetBrainsMono Nerd Font"
                    pixelSize: 9
                  }
                }


                Text {
                  text: root.formatSpeed( root.downloadSpeed)
                  color: "white"
                  font {
                    family: "JetBrainsMono Nerd Font"
                    pixelSize: 12
                    bold: true
                  }
                }
              }
            }
          }


          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            radius: 8
            color: "#1d1d1d"

            RowLayout {
              anchors.fill: parent
              anchors.margins: 10
              spacing: 8

              Text {
                text: "↑"
                color: "#e89aa8"
                font {
                  family: "JetBrainsMono Nerd Font"
                  pixelSize: 18
                }
              }

              ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                  text: "UPLOAD"
                  color: "#777777"
                  font {
                    family: "JetBrainsMono Nerd Font"
                    pixelSize: 9
                  }
                }


                Text {
                    text: root.formatSpeed( root.uploadSpeed)
                    color: "white"
                    font {
                      family: "JetBrainsMono Nerd Font"
                      pixelSize: 12
                      bold: true
                    }
                }
              }
            }
          }
        }


        // =================================================
        // GRAPH
        // =================================================

        RowLayout {
          Layout.fillWidth: true
          spacing: 10

          Text {
            text: "Network activity"
            color: "#777777"
            font {
              family: "JetBrainsMono Nerd Font"
              pixelSize: 10
            }
          }

          Item { Layout.fillWidth: true }

          RowLayout {
            spacing: 8

            Text {
              text: "● Download"
              color: "#75f1fa"
              font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 9
              }
            }


            Text {
              text: "● Upload"
              color: "#e89aa8"
              font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 9
              }
            }
          }
        }


        Rectangle {
          Layout.fillWidth: true
          Layout.fillHeight: true
          radius: 8
          color: "#101010"

          Canvas {
            id: networkGraph
            anchors.fill: parent
            anchors.margins: 6

            onPaint: {
              const ctx = getContext("2d")
              ctx.clearRect( 0, 0, width, height)

              // -------------------------------
              // GRID
              // -------------------------------

              ctx.strokeStyle = "#202020"
              ctx.lineWidth = 1

              for ( let i = 1; i < 4; i++) {
                  const y = height * i / 4
                  ctx.beginPath()
                  ctx.moveTo(0, y)
                  ctx.lineTo( width, y)
                  ctx.stroke()
              }

              // -------------------------------
              // MAX VALUE
              // -------------------------------

              let maxValue = 1024

              for ( const value of root.downloadHistory) {
                maxValue = Math.max( maxValue, value)
              }

              for ( const value of root.uploadHistory) {
                maxValue = Math.max( maxValue, value)
              }

              root.drawGraph( ctx, root.downloadHistory, width, height, maxValue, "#75f1fa")
              root.drawGraph( ctx, root.uploadHistory, width, height, maxValue, "#e89aa8")
            }
          }
        }

        // =================================================
        // INTERFACE
        // =================================================

        RowLayout {
          Layout.fillWidth: true

          Text {
            text: "Interface"
            color: "#666666"
            font {
              family: "JetBrainsMono Nerd Font"
              pixelSize: 10
            }
          }


          Item { Layout.fillWidth: true }

          Text {
            text: root.interfaceName || "-"
            color: "#999999"
            font {
              family: "JetBrainsMono Nerd Font"
              pixelSize: 10
            }
          }
        }
      }
    }
  }

  // =========================================================
  // FUNCTIONS
  // =========================================================

  function updateNetworkStats() {
    if (root.interfaceName === "") return

    statsProcess.running = false
    statsProcess.running = true
  }


  function formatSpeed(bytes) {
    if (!Number.isFinite(bytes) || bytes <= 0) {
      return "0 B/s"
    }

    if (bytes < 1024) {
      return Math.round(bytes) + " B/s"
    }

    if (bytes < 1024 * 1024) {
      return ( bytes / 1024).toFixed(1) + " KB/s"
    }

    if (bytes < 1024 * 1024 * 1024) {
      return ( bytes / (1024 * 1024)).toFixed(1) + " MB/s"
    }

    return ( bytes / (1024 * 1024 * 1024)).toFixed(1) + " GB/s"
  }

  function drawGraph( ctx, values, width, height, max, lineColor) {
    if (!values || values.length < 2) { 
      return 
    }

    ctx.strokeStyle = lineColor
    ctx.lineWidth = 1.5
    ctx.lineJoin = "round"
    ctx.lineCap = "round"

    ctx.beginPath()

    const step = width / Math.max( values.length - 1, 1)

    for ( let i = 0; i < values.length; i++) {
      const x = i * step
      const normalized = Math.min( values[i] / max, 1)
      const y = height - normalized * (height - 8) - 4
      if (i === 0) ctx.moveTo(x, y)
      else ctx.lineTo(x, y)
    }
    ctx.stroke()
  }

    // =========================================================
    // INTERFACE CHANGE
    // =========================================================

  onInterfaceNameChanged: {
    root.previousRx = -1
    root.previousTx = -1

    root.downloadSpeed = 0
    root.uploadSpeed = 0

    root.downloadHistory = []
    root.uploadHistory = []

    if (root.interfaceName !== "") root.updateNetworkStats()
  }


  onConnectedChanged: {
    if (!root.connected) {
      root.downloadSpeed = 0
      root.uploadSpeed = 0

      root.downloadHistory = []
      root.uploadHistory = []

      root.previousRx = -1
      root.previousTx = -1
    }
  }
}
