import QtQuick
import QtQuick.Layouts

Rectangle {
    id: settingIcon

    required property var settingsPanel

    Layout.preferredWidth: 15
    Layout.preferredHeight: 30

    color: "transparent"

    Text {
        anchors.centerIn: parent
        text: "  "
        color: "white"

        font {
            pixelSize: 12
            family: "JetBrainsMono Nerd Font"
        }
    }

    MouseArea {
        id: profileMouse
        anchors.fill: parent

        onClicked: settingIcon.settingsPanel.visible = true
    }
}
