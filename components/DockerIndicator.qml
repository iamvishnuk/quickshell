import Quickshell.Io
import QtQuick

Item {
    id: root

    property int runningContainers: 0

    implicitWidth: runningContainers > 0 ? 20 : 0
    implicitHeight: 30

    visible: runningContainers > 0

    Process {
        id: dockerProcess

        command: ["docker", "ps", "-q"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const output = text.trim();

                root.runningContainers = output.length > 0 ? output.split(/\s+/).length : 0;
            }
        }
    }

    Process {
        id: openLazyDocker
        command: ["ghostty", "--title=Lazy Docker", "-e", "lazydocker"]
    }

    Timer {
        interval: 3000
        running: true
        repeat: true

        onTriggered: {
            if (!dockerProcess.running) {
                dockerProcess.running = true;
            }
        }
    }

    Text {
        anchors.centerIn: parent

        text: "  "
        color: mouseArea.containsMouse ? "#7aa2f7" : "#2496ed"

        font {
            family: "JetBrainsMono Nerd Font"
            pixelSize: 16
        }

        SequentialAnimation on opacity {
            running: root.runningContainers > 0
            loops: Animation.Infinite

            NumberAnimation {
                to: 0.3
                duration: 600
            }

            NumberAnimation {
                to: 1.0
                duration: 600
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
          openLazyDocker.running = true
        }
    }
}
