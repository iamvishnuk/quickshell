import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    Layout.preferredWidth: 20
    Layout.preferredHeight: 30

    property var adapter: Bluetooth.defaultAdapter

    readonly property bool available: adapter !== null && adapter !== undefined
    readonly property bool bluetoothEnabled: available && adapter.enabled
    readonly property bool discovering: available && adapter.discovering
    readonly property var devices: available ? adapter.devices.values : []
    readonly property var connectedDevices: devices.filter(device => device.connected)
    readonly property int connectedCount: connectedDevices.length
    readonly property string icon: {
        if (!root.available)
            return "󰂲";

        if (!root.bluetoothEnabled)
            return "󰂲";
        if (root.connectedCount > 0)
            return "󰂱";

        return "󰂯";
    }

    // ============================================================
    // BAR BUTTON
    // ============================================================

    Item {
        Layout.preferredWidth: 20
        Layout.preferredHeight: 30

        Text {
            id: bluetoothIcon

            anchors.centerIn: parent

            text: root.icon
            color: root.bluetoothEnabled ? "white" : "#777777"

            font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 15
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                bluetoothPopup.visible = !bluetoothPopup.visible;
            }
        }
    }

    // ============================================================
    // POPUP
    // ============================================================

    PopupWindow {
        id: bluetoothPopup
        anchor.item: bluetoothIcon

        anchor.rect.x: root.width / 2 - width / 2
        anchor.rect.y: root.height - 5

        implicitWidth: 360
        implicitHeight: 430
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

                // ==================================================
                // HEADER
                // ==================================================

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    Text {
                        text: root.icon
                        color: root.bluetoothEnabled ? "white" : "#666666"
                        font {
                            family: "JetBrainsMono Nerd Font"
                            pixelSize: 21
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: "Bluetooth"
                            color: "white"
                            font {
                                family: "JetBrainsMono Nerd Font"
                                pixelSize: 14
                                bold: true
                            }
                        }

                        Text {
                            text: {
                                if (!root.available)
                                    return "Bluetooth unavailable";
                                if (!root.enabled)
                                    return "Bluetooth disabled";
                                if (root.connectedCount === 0)
                                    return "No devices connected";
                                if (root.connectedCount === 1)
                                    return "1 device connected";
                                return root.connectedCount + " devices connected";
                            }
                            color: "#888888"
                            font {
                                family: "JetBrainsMono Nerd Font"
                                pixelSize: 10
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // POWER TOGGLE
                    Rectangle {
                        implicitWidth: 42
                        implicitHeight: 22
                        radius: 11
                        color: root.bluetoothEnabled ? "#75f1fa" : "#333333"

                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            anchors.verticalCenter: parent.verticalCenter
                            x: root.bluetoothEnabled ? parent.width - width - 3 : 3
                            color: root.bluetoothEnabled ? "#111111" : "#888888"

                            Behavior on x {
                                NumberAnimation {
                                    duration: 150
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.available) {
                                    root.adapter.enabled = !root.adapter.enabled;
                                }
                            }
                        }
                    }
                }

                // ==================================================
                // CONNECTED DEVICES
                // ==================================================

                Text {
                    text: "CONNECTED"
                    visible: root.connectedCount > 0
                    color: "#777777"

                    font {
                        family: "JetBrainsMono Nerd Font"
                        pixelSize: 9
                        bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    spacing: 4

                    Repeater {
                        model: root.connectedDevices

                        delegate: Rectangle {
                            id: connectedDeviceDelegate

                            required property var modelData

                            Layout.fillWidth: true

                            height: 52

                            radius: 8

                            color: "#202020"

                            RowLayout {
                                anchors.fill: parent

                                anchors.leftMargin: 10
                                anchors.rightMargin: 10

                                spacing: 10

                                Text {
                                    text: connectedDeviceDelegate.modelData.icon ? "󰂱" : "󰂯"
                                    color: "#75f1fa"
                                    font {
                                        family: "JetBrainsMono Nerd Font"
                                        pixelSize: 17
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        Layout.fillWidth: true
                                        text: connectedDeviceDelegate.modelData.name || connectedDeviceDelegate.modelData.deviceName
                                        color: "white"
                                        elide: Text.ElideRight

                                        font {
                                            family: "JetBrainsMono Nerd Font"
                                            pixelSize: 10
                                            bold: true
                                        }
                                    }

                                    Text {
                                        text: connectedDeviceDelegate.modelData.batteryAvailable ? "Connected • " + Math.round(connectedDeviceDelegate.modelData.battery * 100) + "%" : "Connected"

                                        color: "#7ddc9a"
                                        font {
                                            family: "JetBrainsMono Nerd Font"
                                            pixelSize: 8
                                        }
                                    }
                                }

                                Text {
                                    text: "Disconnect"
                                    color: "#ff7777"
                                    font {
                                        family: "JetBrainsMono Nerd Font"
                                        pixelSize: 9
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: connectedDeviceDelegate.modelData.disconnect()
                                    }
                                }
                            }
                        }
                    }
                }

                // ==================================================
                // SCAN
                // ==================================================

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 34
                    radius: 6
                    color: scanMouse.containsMouse ? "#303030" : "#222222"

                    Text {
                        anchors.centerIn: parent
                        text: root.discovering ? "󰑐  Scanning..." : "󰂰  Scan for devices"
                        color: root.bluetoothEnabled ? "white" : "#555555"

                        font {
                            family: "JetBrainsMono Nerd Font"
                            pixelSize: 10
                        }
                    }

                    MouseArea {
                        id: scanMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: root.bluetoothEnabled
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.discovering) {
                                root.adapter.discovering = false;
                            } else {
                                root.adapter.discovering = true;
                            }
                        }
                    }
                }

                // ==================================================
                // DEVICES
                // ==================================================

                Text {
                    text: root.discovering ? "AVAILABLE DEVICES" : "DEVICES"
                    color: "#777777"
                    font {
                        family: "JetBrainsMono Nerd Font"
                        pixelSize: 9
                        bold: true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    radius: 8
                    color: "#101010"

                    ListView {
                        anchors.fill: parent
                        anchors.margins: 4
                        clip: true
                        spacing: 2
                        model: root.devices

                        delegate: Rectangle {
                            id: deviceDelegate

                            required property var modelData
                            width: ListView.view.width
                            height: 56
                            radius: 6

                            color: deviceMouse.containsMouse ? "#252525" : "transparent"

                            RowLayout {
                                anchors.fill: parent

                                anchors.leftMargin: 10
                                anchors.rightMargin: 10

                                spacing: 10

                                // DEVICE ICON

                                Text {
                                    text: {
                                        if (deviceDelegate.modelData.connected)
                                            return "󰂱";
                                        if (deviceDelegate.modelData.paired)
                                            return "󰂯";
                                        return "󰂯";
                                    }

                                    color: deviceDelegate.modelData.connected ? "#75f1fa" : "#888888"

                                    font {
                                        family: "JetBrainsMono Nerd Font"

                                        pixelSize: 16
                                    }
                                }

                                // DEVICE INFO

                                ColumnLayout {
                                    Layout.fillWidth: true

                                    spacing: 2

                                    Text {
                                        Layout.fillWidth: true
                                        text: deviceDelegate.modelData.name || deviceDelegate.modelData.deviceName || "Unknown device"
                                        color: "white"
                                        elide: Text.ElideRight

                                        font {
                                            family: "Inter"
                                            pixelSize: 10
                                            bold: deviceDelegate.modelData.connected
                                        }
                                    }

                                    Text {
                                        text: {
                                            if (deviceDelegate.modelData.pairing)
                                                return "Pairing...";

                                            if (deviceDelegate.modelData.connected)
                                                return deviceDelegate.modelData.batteryAvailable ? "Connected • " + Math.round(deviceDelegate.modelData.battery * 100) + "%" : "Connected";

                                            if (deviceDelegate.modelData.paired)
                                                return "Paired";

                                            return "Available";
                                        }

                                        color: deviceDelegate.modelData.connected ? "#7ddc9a" : "#777777"

                                        font {
                                            family: "JetBrainsMono Nerd Font"

                                            pixelSize: 8
                                        }
                                    }
                                }

                                // ACTION

                                Text {
                                    text: {
                                        if (deviceDelegate.modelData.pairing)
                                            return "...";
                                        if (deviceDelegate.modelData.connected)
                                            return "Disconnect";
                                        if (deviceDelegate.modelData.paired)
                                            return "Connect";
                                        return "Pair";
                                    }

                                    color: deviceDelegate.modelData.connected ? "#ff7777" : "#75f1fa"

                                    font {
                                        family: "Inter"
                                        pixelSize: 9
                                        bold: true
                                    }
                                }
                            }

                            MouseArea {
                                id: deviceMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    if (deviceDelegate.modelData.pairing)
                                        return;
                                    if (deviceDelegate.modelData.connected) {
                                        deviceDelegate.modelData.disconnect();
                                    } else if (deviceDelegate.modelData.paired) {
                                        deviceDelegate.modelData.connect();
                                    } else {
                                        deviceDelegate.modelData.pair();
                                    }
                                }
                            }
                        }

                        // EMPTY STATE

                        Text {
                            anchors.centerIn: parent

                            visible: root.devices.length === 0

                            text: {
                                if (!root.bluetoothEnabled)
                                    return "Bluetooth is disabled";

                                if (root.discovering)
                                    return "Searching for devices...";

                                return "No devices found";
                            }

                            color: "#666666"

                            font {
                                family: "JetBrainsMono Nerd Font"

                                pixelSize: 10
                            }
                        }
                    }
                }

                // ==================================================
                // FOOTER
                // ==================================================

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true

                        text: root.available ? root.adapter.name : "No adapter"

                        color: "#555555"

                        font {
                            family: "JetBrainsMono Nerd Font"

                            pixelSize: 8
                        }
                    }

                    Text {
                        text: root.devices.length + " devices"

                        color: "#555555"

                        font {
                            family: "JetBrainsMono Nerd Font"

                            pixelSize: 8
                        }
                    }
                }
            }
        }
    }
}
