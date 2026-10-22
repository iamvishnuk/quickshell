import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    Layout.preferredWidth: 20
    Layout.preferredHeight: 30

    Process {
        id: shutdownProcess
        command: ["systemctl", "poweroff"]
    }

    Process {
        id: restartProcess
        command: ["systemctl", "reboot"]
    }

    Process {
        id: lockProcess
        command: ["qs", "ipc", "call", "lockscreen", "lock"]
    }

    Item {
        Layout.preferredHeight: 30
        Layout.preferredWidth: 20

        Text {
            anchors.centerIn: parent
            text: "󰐥"
            color: mouseArea.containsMouse ? "white" : "red"

            font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 14
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                powerPopup.visible = !powerPopup.visible;
            }
        }
    }

    PopupWindow {
        id: powerPopup

        anchor.item: root
        grabFocus: true

        anchor.rect.x: root.width / 2 - width / 2
        anchor.rect.y: root.height + 5

        implicitWidth: 180
        implicitHeight: 180

        color: "transparent"

        Rectangle {
            anchors.fill: parent

            color: "#1a1b26"
            radius: 8

            border {
                color: "#414868"
                width: 1
            }

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: 12
                }

                spacing: 8

                Text {
                    Layout.alignment: Qt.AlignHCenter

                    text: "Power"
                    color: "white"

                    font {
                        pixelSize: 14
                        bold: true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32

                    radius: 5
                    color: shutdownMouse.containsMouse ? "#75f1fa" : "#24283b"

                    Text {
                        anchors.centerIn: parent
                        text: "󰐥  Shutdown"
                        color: shutdownMouse.containsMouse ? "black" : "white"
                    }

                    MouseArea {
                        id: shutdownMouse
                        hoverEnabled: true
                        anchors.fill: parent
                        onClicked: {
                            shutdownProcess.running = true;
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32

                    radius: 5
                    color: restartMouse.containsMouse ? "#75f1fa" : "#24283b"

                    Text {
                        anchors.centerIn: parent
                        text: "󰜉  Restart"
                        color: restartMouse.containsMouse ? "black" : "white"
                    }

                    MouseArea {
                        id: restartMouse
                        hoverEnabled: true
                        anchors.fill: parent
                        onClicked: {
                            restartProcess.running = true;
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32

                    radius: 5
                    color: lockMouse.containsMouse ? "#75f1fa" : "#24283b"

                    Text {
                        anchors.centerIn: parent
                        text: "󰌾  Lock"
                        color: lockMouse.containsMouse ? "black" : "white"
                    }

                    MouseArea {
                        id: lockMouse
                        hoverEnabled: true
                        anchors.fill: parent
                        onClicked: {
                            lockProcess.running = true;
                        }
                    }
                }
            }
        }
    }
}
