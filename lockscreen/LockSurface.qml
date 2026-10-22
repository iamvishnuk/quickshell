import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root

    property var monitor
    property string wallpaperPath: ""

    Process {
        id: wallpaperQuery

        command: ["awww", "query", "-j"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const outputsByNamespace = JSON.parse(text);
                    let selectedPath = "";

                    for (const namespace in outputsByNamespace) {
                        const outputs = outputsByNamespace[namespace];

                        for (const output of outputs) {
                            if (output.name === root.monitor?.name && output.displaying?.image) {
                                selectedPath = output.displaying.image;
                                break;
                            }
                        }

                        if (selectedPath)
                            break;
                    }

                    // Fall back to another output if no matching wallpaper was found.
                    if (!selectedPath) {
                        for (const namespace in outputsByNamespace) {
                            for (const output of outputsByNamespace[namespace]) {
                                if (output.displaying?.image) {
                                    selectedPath = output.displaying.image;
                                    break;
                                }
                            }

                            if (selectedPath)
                                break;
                        }
                    }

                    root.wallpaperPath = selectedPath;

                    if (!selectedPath)
                        console.warn("No wallpaper image found in awww query output.");
                } catch (error) {
                    console.warn("Failed to read current awww wallpaper:", error);
                }
            }
        }
    }

    required property var context

    color: "#1a1b26"

    property var currentDate: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            root.currentDate = new Date();
        }
    }

    Image {
        id: wallpaperImage

        anchors.fill: parent

        source: root.wallpaperPath ? "file://" + root.wallpaperPath : ""

        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: true
    }

    Rectangle {
        anchors.fill: parent
        color: "#99000000"
    }

    ColumnLayout {
        anchors.centerIn: parent

        width: Math.min(parent.width - 48, 380)
        spacing: 12

        Text {
            Layout.alignment: Qt.AlignHCenter

            text: Qt.formatTime(root.currentDate, "hh:mm:ss AP")
            color: "#c0caf5"

            font {
                family: "Space Grotesk"
                pixelSize: 76
                weight: Font.Bold
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 28

            text: Qt.formatDate(root.currentDate, "dddd, d MMMM")
            color: "#a9b1d6"

            font {
                family: "Space Grotesk"
                pixelSize: 16
            }
        }

        TextField {
            id: passwordBox

            Layout.fillWidth: true
            implicitHeight: 46

            placeholderText: "Enter your password"
            echoMode: TextInput.Password
            passwordCharacter: "●"

            color: "#c0caf5"
            placeholderTextColor: "#565f89"
            inputMethodHints: Qt.ImhSensitiveData

            focus: true
            enabled: !root.context.unlockInProgress

            background: Rectangle {
                radius: 8
                color: "#24283b"
                border.width: passwordBox.activeFocus ? 2 : 1
                border.color: passwordBox.activeFocus ? "#7aa2f7" : "#414868"
            }

            onTextChanged: {
                if (root.context.currentText !== text) {
                    root.context.currentText = text;
                }
            }

            onAccepted: {
                root.context.tryUnlock();
            }

            Connections {
                target: root.context

                function onCurrentTextChanged() {
                    if (passwordBox.text !== root.context.currentText) {
                        passwordBox.text = root.context.currentText;
                    }
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter

            visible: root.context.showFailure
            text: "Incorrect password. Try again."
            color: "#f7768e"
            font.pixelSize: 12
        }
    }
}
