import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RowLayout {
  id: root

  Layout.preferredWidth: 20
  Layout.preferredHeight: 30

  property var sink: Pipewire.defaultAudioSink
  property var source: Pipewire.defaultAudioSource

  readonly property bool ready: sink && sink.ready
  readonly property bool muted: ready && sink.audio.muted
  readonly property int vol: ready
      ? Math.round(sink.audio.volume * 100)
      : 0

  readonly property string icon : {
    if (!ready) return String.fromCodePoint(0xF0581)
    if (muted) return "󰝟"

    if (vol === 0) return String.fromCodePoint(0xF0581)
    if (vol < 34) return String.fromCodePoint(0xF057F)
    if (vol < 67) return String.fromCodePoint(0xF0580)

    return String.fromCodePoint(0xF057E)
  }

  Process {
    id: wiremixProcess
    command: ["ghostty", "--title=wiremix", "-e", "wiremix" ]
  }

  Text {
    anchors.centerIn : parent

    text: icon
    color: "white"

    font {
      family: "JetBrainsMono Nerd Font"
      pixelSize: 14
    }
  }

  MouseArea {
    id: mouseArea

    anchors.fill: parent
    hoverEnabled: true

    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: function (mouse) {
      if(!root.ready) {
        return
      }

      if(mouse.button === Qt.LeftButton) {
        root.sink.audio.muted = !root.sink.audio.muted
      }

      if(mouse.button === Qt.RightButton) {
        volumePopup.visible = !volumePopup.visible
      }
    }
  }

  PopupWindow {
    id: volumePopup
    anchor.item: root
    grabFocus: true

    anchor.rect.x : root.width / 2 - width / 2
    anchor.rect.y : root.height + 5

    width: 280
    height: 100

    color: "transparent"

    Rectangle {
      anchors.fill: parent
      color: "#1a1b26"
      radius: 5

      border {
        color: "#414868"
        width: 1
      }

      ColumnLayout {
        anchors {
          fill: parent
          margins: 14
        }

        spacing: 18

        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 30
          spacing: 0

          Text {
            text: "Audio Controls"
            color: "white"

            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true

            font {
              pixelSize: 15
              bold: true
            }
          }

          Rectangle {
            width: 30
            height: 30
            color: "transparent"

            Text {
              anchors.centerIn : parent
              text: " "
              color: "white"
              
              font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 16
              }
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor

              onClicked: {
                wiremixProcess.running = true
                volumePopup.visible = false
              }
            }

          }
        }

        RowLayout {
          Layout.fillWidth: true

          Text {
            text: root.muted ? "󰝟" : "󰕾"
            color: "white"

            font {
              family: "JetBrainsMono Nerd Font"
              pixelSize: 16
            }
          }

          Slider {
            id: volumeSlider

            Layout.fillWidth: true

            from: 0
            to: 1

            value: root.ready ? root.sink.audio.volume : 0

            onMoved: {
              if(!root.ready) return

              root.sink.audio.volume = value
              root.sink.audio.muted = value <= 0
            }
          }

          Text {
            text: `${root.vol}%`
            color: "white"
            horizontalAlignment: Text.AlignRight
          }
        }


      }
    }
  }


  PwObjectTracker {
    objects: {
      const objects = [root.sink, root.source];
      return objects;
    }
  }
}
