pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    implicitWidth: 900
    implicitHeight: 500

    visible: false

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    property string selectedMenuId: "0001"

    Rectangle {
        anchors.fill: parent
        color: "#1a1b26"
        radius: 5

        border {
            color: "#414868"
            width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            RowLayout {
                Layout.alignment: Qt.AlignVCenter

                // <-- Header -->
                Text {
                    Layout.fillWidth: true
                    text: "Customizations"
                    color: "white"
                    font {
                        family: "Inter"
                        pixelSize: 18
                        bold: true
                    }
                }

                // <-- Close Button -->
                Rectangle {
                    implicitWidth: 30
                    implicitHeight: 30
                    color: "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: " 󰅚 "
                        color: "white"
                        font {
                            family: "JetBrainsMono Nerd Font"
                            pixelSize: 20
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.visible = false;
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: "#313244"
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: "transparent"

                RowLayout {
                    anchors.fill: parent

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 250
                        color: "transparent"

                        // <-- Menu Items -->
                        ListView {
                            id: menuList
                            spacing: 5
                            anchors.fill: parent
                            clip: true

                            model: [
                                {
                                    id: "0001",
                                    title: "Wallpapers",
                                    icon: "  "
                                },
                                {
                                    id: "0002",
                                    title: "Status Bar",
                                    icon: "  "
                                }
                            ]

                            delegate: Rectangle {
                                id: menuItemDelegate

                                required property var modelData

                                color: root.selectedMenuId === modelData.id ? "#414868" : "transparent"
                                width: menuList.width
                                height: 40
                                radius: 5

                                border {
                                    color: "#414868"
                                    width: 1
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    spacing: 10

                                    Text {
                                        text: menuItemDelegate.modelData.icon
                                        color: "white"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 18
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: menuItemDelegate.modelData.title
                                        color: "white"
                                        font.family: "Inter"
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        root.selectedMenuId = menuItemDelegate.modelData.id;
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        color: "transparent"
                        radius: 5
                        clip: true

                        Loader {
                            id: menuItemLoader
                            anchors.fill: parent
                            source: "Wallpaper.qml"
                        }
                    }
                }
            }
        }
    }
}
