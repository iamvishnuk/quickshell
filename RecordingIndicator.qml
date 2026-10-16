import Quickshell.Io
import Quickshell.Widgets
import QtQuick

Item {
    id: root

    property bool recording: false

    implicitWidth: recording ? 14 : 0
    implicitHeight: 30
    visible: recording

    Process {
        id: statusProcess

        command: ["obs-cmd", "recording", "status-active"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const result = text.trim().toLowerCase();
                root.recording = result === "true" || result.includes('"outputactive":true') || result.includes("recording is active");
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.recording = false;
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            if (!statusProcess.running) {
                statusProcess.running = true;
            }
        }
    }

    IconImage {
        anchors.centerIn: parent

        source: "file:///home/vishnu/.config/quickshell/assets/obs-studio.png"

        implicitSize: 14

        mipmap: false
        asynchronous: false
        SequentialAnimation on opacity {
            running: root.recording
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
}
