import Quickshell
import QtQuick
import QtQuick.Layouts
import "./notification"
import "./settings"

Scope {
    NotificationService {
        id: notificationService
    }

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
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }

                spacing: 10

                ClockWidget {}
                WeatherWidget {}
            }

            RowLayout {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: 5
                }

                spacing: 10

                SpotifyWidget {}
                RecordingIndicator {}
                SystemMonitor {}

                NotificationWidget {
                    service: notificationService
                    showToast: modelData === Quickshell.screens[0]
                }

                BluetoothWidget {}
                NetworkWidget {}
                VolumeWidget {}
                BatteryWidget {}
                SettingsIcon {
                    settingsPanel: settingsPanelWindow
                }
                PowerWidget {}

            }

            SettingsPanel {
                id: settingsPanelWindow
            }
        }
    }
}
