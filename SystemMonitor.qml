import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    Layout.preferredWidth: 100
    Layout.preferredHeight: 30
    spacing: 0

    property real cpuUsage: 0
    property real memoryUsage: 0
    property real previousIdle: 0
    property real previousTotal: 0

    property bool popupOpen: false
    property string systemStats: "Loading system statistics..."

    // Refresh the lightweight bar indicators.
    Timer {
        interval: 2000
        running: true
        repeat: true

        onTriggered: {
            if (!cpuProcess.running)
                cpuProcess.running = true

            if (!memoryProcess.running)
                memoryProcess.running = true
        }
    }

    // Refresh detailed statistics only while the popup is open.
    Timer {
        interval: 2000
        running: root.popupOpen
        repeat: true

        onTriggered: {
            if (!systemProcess.running)
                systemProcess.running = true
        }
    }

    Process {
        id: cpuProcess
        command: ["sh", "-c", "head -n 1 /proc/stat"]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/)
                if (parts.length < 5)
                    return

                const user = Number(parts[1])
                const nice = Number(parts[2])
                const system = Number(parts[3])
                const idle = Number(parts[4])
                const iowait = Number(parts[5] || 0)
                const irq = Number(parts[6] || 0)
                const softirq = Number(parts[7] || 0)
                const steal = Number(parts[8] || 0)

                const idleTime = idle + iowait
                const total = user + nice + system + idle
                    + iowait + irq + softirq + steal

                if (root.previousTotal > 0) {
                    const totalDelta = total - root.previousTotal
                    const idleDelta = idleTime - root.previousIdle

                    if (totalDelta > 0) {
                        root.cpuUsage = Math.max(0, Math.min(
                            100,
                            (1 - idleDelta / totalDelta) * 100
                        ))
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
            "sh", "-c",
            "awk '/MemTotal:/ {t=$2} /MemAvailable:/ {a=$2} END {if(t>0) printf \"%.0f\\n\", (t-a)*100/t; else print 0}' /proc/meminfo"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = Number(text.trim())
                if (Number.isFinite(value))
                    root.memoryUsage = value
            }
        }
    }

    // Collect detailed system information.
    Process {
        id: systemProcess

        command: [
            "sh", "-c",
            `
            echo "CPU MODEL"
            awk -F ': ' '/model name/ {print $2; exit}' /proc/cpuinfo

            echo
            echo "LOAD AVERAGE"
            awk '{print $1 "  /  " $2 "  /  " $3}' /proc/loadavg

            echo
            echo "UPTIME"
            uptime -p 2>/dev/null || cat /proc/uptime

            echo
            echo "MEMORY"
            awk '
              /MemTotal:/ {t=$2}
              /MemAvailable:/ {a=$2}
              /SwapTotal:/ {st=$2}
              /SwapFree:/ {sf=$2}
              END {
                printf "RAM: %.2f / %.2f GiB used\\n", (t-a)/1048576, t/1048576
                printf "RAM usage: %.0f%%\\n", t>0 ? (t-a)*100/t : 0
                printf "Swap: %.2f / %.2f GiB used\\n", (st-sf)/1048576, st/1048576
              }
            ' /proc/meminfo

            echo
            echo "DISK"
            df -h / | awk 'NR==2 {printf "Root: %s used of %s (%s)\\n", $3, $2, $5}'

            echo
            echo "TEMPERATURE SENSORS"
            if command -v sensors >/dev/null 2>&1; then
              sensors 2>/dev/null | grep -E 'Package id|Tctl:|Tdie:|CPU Temperature:|edge:|junction:' | head -n 8
            else
              echo "Install lm_sensors to read temperatures."
            fi

            echo
            echo "GPU"
            if command -v nvidia-smi >/dev/null 2>&1; then
              nvidia-smi --query-gpu=name,utilization.gpu,temperature.gpu,memory.used,memory.total --format=csv 2>/dev/null
            else
              found=0
              for f in /sys/class/drm/card*/device/gpu_busy_percent; do
                if [ -r "$f" ]; then
                  printf "GPU usage: %s%%\\n" "$(cat "$f")"
                  found=1
                fi
              done
              if [ "$found" -eq 0 ]; then
                echo "GPU usage unavailable for this driver."
              fi
              echo "GPU name, temperature and VRAM depend on your driver."
            fi

            echo
            echo "SYSTEM"
            printf "Hostname: "
            hostname
            printf "Kernel: "
            uname -r
            `
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.systemStats = text.trim()
            }
        }
    }

    // CPU indicator.
    Rectangle {
        Layout.preferredWidth: 50
        Layout.preferredHeight: 30
        color: cpuMouse.containsMouse ? "#313244" : "transparent"
        radius: 5

        RowLayout {
            anchors.centerIn: parent
            spacing: 3

            Text {
                text: ""
                color: "white"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
            }

            Text {
                text: Math.round(root.cpuUsage) + "%"
                color: "white"
                font.family: "Inter"
                font.pixelSize: 12
            }
        }

        MouseArea {
            id: cpuMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root.popupOpen = !root.popupOpen
                if (root.popupOpen && !systemProcess.running)
                    systemProcess.running = true
            }
        }
    }

    // Memory indicator.
    Rectangle {
        Layout.preferredWidth: 50
        Layout.preferredHeight: 30
        color: memoryMouse.containsMouse ? "#313244" : "transparent"
        radius: 5

        RowLayout {
            anchors.centerIn: parent
            spacing: 3

            Text {
                text: ""
                color: "white"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
            }

            Text {
                text: Math.round(root.memoryUsage) + "%"
                color: "white"
                font.family: "Inter"
                font.pixelSize: 12
            }
        }

        MouseArea {
            id: memoryMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root.popupOpen = !root.popupOpen
                if (root.popupOpen && !systemProcess.running)
                    systemProcess.running = true
            }
        }
    }

    // System statistics popup.
    PopupWindow {
        id: statsPopup

        anchor.item: root
        anchor.rect.x: root.width / 2 - width / 2
        anchor.rect.y: root.height + 6

        visible: root.popupOpen
        implicitWidth: 440
        implicitHeight: 520
        color: "transparent"
        grabFocus: true

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: "#181825"
            border.width: 1
            border.color: "#45475a"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "System Monitor"
                        color: "#cdd6f4"
                        font.family: "Inter"
                        font.pixelSize: 18
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "LIVE"
                        color: "#a6e3a1"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                    }

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 5
                        color: closeMouse.containsMouse ? "#45475a" : "#313244"

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: "#cdd6f4"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.popupOpen = false
                        }
                    }
                }

                // CPU and memory summary cards.
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        radius: 7
                        color: "#313244"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 5

                            Text {
                                text: "CPU USAGE"
                                color: "#a6adc8"
                                font.family: "Inter"
                                font.pixelSize: 10
                            }

                            Text {
                                text: Math.round(root.cpuUsage) + "%"
                                color: "#89b4fa"
                                font.family: "Inter"
                                font.pixelSize: 23
                                font.bold: true
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        radius: 7
                        color: "#313244"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 5

                            Text {
                                text: "RAM USAGE"
                                color: "#a6adc8"
                                font.family: "Inter"
                                font.pixelSize: 10
                            }

                            Text {
                                text: Math.round(root.memoryUsage) + "%"
                                color: "#a6e3a1"
                                font.family: "Inter"
                                font.pixelSize: 23
                                font.bold: true
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#45475a"
                }

                Text {
                    text: "HARDWARE & SYSTEM DETAILS"
                    color: "#a6adc8"
                    font.family: "Inter"
                    font.pixelSize: 10
                    font.bold: true
                }

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: width
                    contentHeight: detailsText.implicitHeight
                    clip: true

                    Text {
                        id: detailsText
                        width: parent.width
                        text: root.systemStats
                        color: "#cdd6f4"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        lineHeight: 1.35
                        wrapMode: Text.Wrap
                    }
                }

                Text {
                    text: "Refreshes every 2 seconds while open"
                    color: "#6c7086"
                    font.family: "Inter"
                    font.pixelSize: 10
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }

    Component.onCompleted: {
        cpuProcess.running = true
        memoryProcess.running = true
    }
}
