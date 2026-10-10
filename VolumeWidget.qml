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


  // Dynamically discover output sinks.
  readonly property var outputDevices: {
    const nodes = Pipewire.nodes.values
    const availabeNodes = nodes.filter(node =>
      node &&
      node.isSink &&
      !node.isStream &&
      node.audio
    )
    console.log("--->",availabeNodes[1].name)
    console.log("--->",availabeNodes[1].description)
    console.log("--->",availabeNodes[1].nickname)

    return availabeNodes
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
    // visible: true

    anchor.rect.x : root.width / 2 - width / 2
    anchor.rect.y : root.height + 5

    width: 280
    height: 180

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

        spacing: 5

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


        Rectangle {
          Layout.fillWidth: true
          height: 1
          color: "#313244"
        }

        ColumnLayout {
          Layout.fillWidth: parent
          spacing: 10

          Text {
            text: "Output Devices"
            color: "#a9b1d6"
            font.pixelSize: 12
            font.family: "Inter"
          }

          ComboBox {
            id: outputSelector

            Layout.fillWidth: true
            implicitHeight: 36

            model: root.outputDevices
            textRole: "description"

            // Closed selector
            background: Rectangle {
              radius: 6
              color: outputSelector.hovered
              ? "#292e42"
              : "#24283b"

              border.color: outputSelector.activeFocus
              ? "#7aa2f7"
              : "#414868"

              border.width: 1
            }

            // Selected output text
            contentItem: Text {
              leftPadding: 10
              rightPadding: 30

              text: outputSelector.displayText
              color: "#c0caf5"

              font.family: "Inter"
              font.pixelSize: 12

              verticalAlignment: Text.AlignVCenter
              elide: Text.ElideRight
            }

            // Dropdown arrow
            indicator: Text {
              x: outputSelector.width - width - 10
              y: (outputSelector.height - height) / 2

              text: outputSelector.popup.visible ? "󰅃" : "󰅀"
              color: "#7aa2f7"

              font.family: "Inter"
              font.pixelSize: 14
            }

            // Dropdown menu
            popup: Popup {
              y: outputSelector.height + 4
              width: outputSelector.width
              padding: 4

              implicitHeight: Math.min(
                contentItem.implicitHeight + padding * 2,
                180
              )

              contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: outputSelector.popup.visible
                ? outputSelector.delegateModel
                : null

                currentIndex: outputSelector.highlightedIndex

                ScrollIndicator.vertical: ScrollIndicator {}
              }

              background: Rectangle {
                color: "#1a1b26"
                radius: 6
                border.color: "#414868"
                border.width: 1
              }
            }

            delegate: ItemDelegate {
              required property var modelData
              required property int index

              width: outputSelector.width
              height: 34

              highlighted: outputSelector.highlightedIndex === index

              background: Rectangle {
                radius: 4

                color: parent.highlighted
                ? "#292e42"
                : "transparent"
              }

              contentItem: RowLayout {
                spacing: 8

                Text {
                  text: "󰓃"
                  color: parent.parent.highlighted
                  ? "#7aa2f7"
                  : "#565f89"

                  font.family: "JetBrainsMono Nerd Font"
                  font.pixelSize: 14
                }

                Text {
                  Layout.fillWidth: true

                  text: modelData.nickname ||
                  modelData.description ||
                  modelData.name ||
                  "Audio output"

                  color: parent.parent.highlighted
                  ? "#c0caf5"
                  : "#a9b1d6"

                  font.family: "Inter"
                  font.pixelSize: 12

                  elide: Text.ElideRight
                }

                Text {
                  visible: modelData === root.sink
                  text: "󰄬"
                  color: "#9ece6a"

                  font.family: "JetBrainsMono Nerd Font"
                  font.pixelSize: 14
                }
              }

              onClicked: {
                outputSelector.currentIndex = index
                Pipewire.preferredDefaultAudioSink = modelData
                outputSelector.popup.close()
              }
            }

            displayText: {
              if (!root.ready)
              return "No output available"

              return root.sink.nickname ||
              root.sink.description ||
              root.sink.name ||
              "Audio output"
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
              implicitHeight: 24

              from: 0
              to: 1
              value: root.ready ? root.sink.audio.volume : 0

              onMoved: {
                if (!root.ready)
                return

                root.sink.audio.volume = value
                root.sink.audio.muted = value <= 0
              }

              background: Rectangle {
                x: volumeSlider.leftPadding
                y: volumeSlider.topPadding +
                (volumeSlider.availableHeight - height) / 2

                width: volumeSlider.availableWidth
                height: 5

                radius: 3
                color: "#414868"

                // Filled portion
                Rectangle {
                  width: volumeSlider.visualPosition * parent.width
                  height: parent.height

                  radius: parent.radius
                  color: "#7aa2f7"
                }
              }

              handle: Rectangle {
                x: volumeSlider.leftPadding +
                volumeSlider.visualPosition *
                (volumeSlider.availableWidth - width)

                y: volumeSlider.topPadding +
                (volumeSlider.availableHeight - height) / 2

                width: 13
                height: 13
                radius: width / 2

                color: volumeSlider.pressed
                ? "#bb9af7"
                : "#c0caf5"

                border.color: "#7aa2f7"
                border.width: 2
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
  }


  PwObjectTracker {
    objects: {
      const objects = [root.sink, root.source];
      return objects;
    }
  }
}
