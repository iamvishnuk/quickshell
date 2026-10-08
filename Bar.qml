import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            color: "#90000000"

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 30

            ClockWidget {
                anchors.centerIn: parent
            }

            WorkspaceWidget {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 5
                }

                currentScreen: modelData
            }

            RowLayout {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: 5
                }
                spacing: 10


                BluetoothWidget {}
                NetworkWidget {}
                VolumeWidget {}
                BatteryWidget {}
                PowerWidget {}

            }
        }
    }
}
