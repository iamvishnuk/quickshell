import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    required property var currentScreen
    spacing: 2

    Repeater {
        model: Hyprland.workspaces.values.filter(
            ws => ws.monitor?.name === root.currentScreen?.name
        )

        delegate: Rectangle {
            id: workspaceItem

            required property var modelData
            property bool isActive: Hyprland.focusedWorkspace?.id === modelData.id
            property var workspaceWindows: Hyprland.toplevels.values.filter( window => window.workspace?.id === modelData.id)

            radius: 5

            // Subtle background instead of bright cyan
            color: isActive ? "#303030" : "transparent"

            // Let the contents determine the width
            implicitWidth: workspaceContent.implicitWidth + 10
            implicitHeight: 30
            Layout.preferredWidth: implicitWidth
            Layout.preferredHeight: 30

            // ----------------------------------------------------
            // WORKSPACE CONTENT
            // ----------------------------------------------------

            RowLayout {
                id: workspaceContent
                anchors.centerIn: parent
                spacing: 4

                // ------------------------------------------------
                // WORKSPACE NUMBER
                // ------------------------------------------------

                Text {
                    text: workspaceItem.modelData.id
                    color: "white"
                    font {
                        family: "JetBrainsMono Nerd Font"
                        pixelSize: 12
                        bold: true
                    }
                    Layout.alignment: Qt.AlignVCenter
                }

                // ------------------------------------------------
                // APPLICATION ICONS
                // ------------------------------------------------

                Repeater {
                    model: workspaceItem.workspaceWindows

                    delegate: Item {
                        required property var modelData

                        width: 15
                        height: 15

                        Layout.alignment: Qt.AlignVCenter

                        // ----------------------------------------
                        // APP ID
                        // ----------------------------------------

                        property string appId: modelData.wayland?.appId || ""

                        property string normalizedAppId: {
                            const id = appId.toLowerCase()
                            if (id.includes("youtube.com")) {
                                return "youtube"
                            }
                            if (id.includes("tradingview.com")) {
                                return "tradingview"
                            }
                            if (id.includes("hotstar.com")) {
                                return "hotstar"
                            }
                            if (id.includes("whatsapp.com")) {
                                return "whatsapp"
                            }
                            return appId
                        }

                        // ----------------------------------------
                        // DESKTOP ENTRY
                        // ----------------------------------------

                        property var desktopEntry: normalizedAppId !== "" ? DesktopEntries.heuristicLookup(normalizedAppId) : null

                        // ----------------------------------------
                        // ICON NAME
                        // ----------------------------------------

                        property string iconName: desktopEntry?.icon || ""

                        // ----------------------------------------
                        // CUSTOM ICON PATH
                        // ----------------------------------------
                        property string customIconPath: {
                            switch (normalizedAppId) {
                                case "youtube":
                                    return "file:///home/vishnu/.local/share/icons/hicolor/scalable/apps/youtube.png"
                                case "tradingview":
                                    return "file:///home/vishnu/.local/share/icons/hicolor/scalable/apps/tradingview.svg"
                                case "hotstar":
                                    return "file:///home/vishnu/.local/share/icons/hicolor/scalable/apps/hotstar.webp"
                                case "whatsapp":
                                    return "file:///home/vishnu/.config/quickshell/assets/whatsapp.png"
                                default:
                                    return ""
                            }
                        }

                        // ----------------------------------------
                        // ICON PATH
                        // ----------------------------------------

                        property string iconPath: customIconPath !== "" ? customIconPath : iconName !== "" ? Quickshell.iconPath( iconName) : ""

                        // ----------------------------------------
                        // ICON
                        // ----------------------------------------

                        IconImage {
                            anchors.fill: parent
                            source: parent.iconPath
                            visible: source !== ""
                            asynchronous: true
                            mipmap: true
                            opacity: 1
                        }

                        // ----------------------------------------
                        // FALLBACK
                        // ----------------------------------------

                        Text {
                            anchors.centerIn: parent
                            visible: parent.iconPath === ""
                            text: "󰣆"
                            color: "#aaaaaa"
                            font {
                                family: "JetBrainsMono Nerd Font"
                                pixelSize: 11
                            }
                        }

                        // ----------------------------------------
                        // CLICK
                        // ----------------------------------------

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                modelData.wayland?.activate()
                            }
                        }
                    }
                }
            }

        }
    }
}
