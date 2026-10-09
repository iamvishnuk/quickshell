import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts

Item {
  id: root

  property var spotify: {
    for (let player of Mpris.players.values) {
      if ( player.identity.toLowerCase().includes("spotify")) {
        return player
      }
    }
    return null
  }

  readonly property bool active: spotify !== null

  visible: active
  implicitWidth: active ? content.implicitWidth : 0
  implicitHeight: 30

  RowLayout {
    id: content

    anchors.fill: parent
    spacing: 8

    // Rectangle {
    //   Layout.alignment: Qt.AlignVCenter
    //   Layout.preferredWidth: 15
    //   Layout.preferredHeight: 15
    //   radius: 100
    //   color: "black"
    //
    //   Text {
    //     anchors.centerIn: parent
    //     text: ""
    //     color: "#1DB954"
    //     font.family: "JetBrainsMono Nerd Font"
    //     font.pixelSize: 20
    //   }
    // }

    Rectangle {
      Layout.preferredWidth: 25
      Layout.preferredHeight: 25

      radius: 5
      clip: true
      color: "black"

      Image {
        anchors.fill: parent
        source: root.spotify ? root.spotify.trackArtUrl : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        visible: status === Image.Ready
      }

      Text {
        anchors.centerIn: parent
        text: "󰓇"
        color: "#1DB954"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 18
        visible: parent.children[0].status !== Image.Ready
      }
    }

    ColumnLayout {
      Layout.maximumWidth: 150
      Layout.minimumWidth: 60
      spacing: 1

      Text {
        Layout.fillWidth: true
        text: root.spotify ? root.spotify.trackTitle : ""
        color: "#ffffff"
        font.family: "Inter"
        font.pixelSize: 11
        elide: Text.ElideRight
      }

      Text {
        Layout.fillWidth: true
        text: root.spotify ? root.spotify.trackArtist : ""
        color: "#a6abb5"
        font.family: "Inter"
        font.pixelSize: 10
        elide: Text.ElideRight
      }
    }

    Rectangle {
      Layout.preferredWidth: 24
      Layout.preferredHeight: 26
      radius: 5
      color: previousMouse.containsMouse ? "#353943" : "transparent"

      Text {
        anchors.centerIn: parent
        text: "󰒮"
        color: "#ffffff"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 16
      }

      MouseArea {
        id: previousMouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
          if (root.spotify && root.spotify.canGoPrevious) {
            root.spotify.previous()
          }
        }
      }
    }

    Rectangle {
      Layout.preferredWidth: 26
      Layout.preferredHeight: 26
      radius: 5
      color: playMouse.containsMouse ? "#353943" : "transparent"

      Text {
        anchors.centerIn: parent
        text: root.spotify && root.spotify.isPlaying ? "󰏤" : "󰐊"
        color: "#ffffff"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 17
      }

      MouseArea {
        id: playMouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
          if (root.spotify && root.spotify.canTogglePlaying) {
            root.spotify.togglePlaying()
          }
        }
      }
    }

    Rectangle {
      Layout.preferredWidth: 24
      Layout.preferredHeight: 26
      radius: 5
      color: nextMouse.containsMouse ? "#353943" : "transparent"

      Text {
        anchors.centerIn: parent
        text: "󰒭"
        color: "#ffffff"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 16
      }

      MouseArea {
        id: nextMouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
          if (root.spotify && root.spotify.canGoNext) {
            root.spotify.next()
          }
        }
      }
    }
  }
}
