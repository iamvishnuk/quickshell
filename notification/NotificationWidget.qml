import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RowLayout {
  id: root

  Layout.preferredWidth: 20
  Layout.preferredHeight: 30

  required property var service
  required property bool showToast

  // property bool dnd: false
  // property int dndDuration: 0

  Text {
    id: notificationIcon
    anchors.centerIn: parent
    text: service.dnd ? "󰂛" : "󰂚"
    color: service.dnd ? "red" : "white"

    font {
      family: "JetBrainsMono Nerd Font"
      pixelSize: 14
    }
  }

  MouseArea {
    id: notificationMouse
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      notificationPopup.visible = !notificationPopup.visible
    }
  }

  PopupWindow {
    id: notificationPopup
    anchor.item: notificationIcon
    anchor.rect.x: root.width / 2 - width / 2
    anchor.rect.y: root.height - 5

    implicitHeight: 650
    implicitWidth: 420
    color: "transparent"
    // visible: true
    grabFocus: true

    Rectangle {
      anchors.fill: parent
      radius: 10
      color: "#151515"
      border { width: 1
        color: "#45475a"
      }

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // <----- Header ----->
        RowLayout {

          Text {
            text: "Notifications"
            color: "white"
            font {
              family: "Inter"
              pixelSize: 18
              bold: true
            }
            Layout.fillWidth: true
          }

          Text {
            text: service.trackedNotifications.length;
            visible: service.trackedNotifications.length > 0
            color: "#a6adc8"
            font {
              family: "JetBrainsMono Nerd Font"
              pixelSize: 12
            }
          }

          Rectangle {
            width: 30
            height: 30
            radius: 5
            color: "#313244"

            Text {
              anchors.centerIn: parent
              text: service.dnd ? "󰂛" : "󰂚"
              color: service.dnd ? "red" : "white"
              font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 15
              }
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                service.toggleDnd()
              }
            }
          }

          Rectangle {
            width: 30
            height: 30
            radius: 5
            color: "#313244"

            Text {
              anchors.centerIn: parent
              text: "󰆴"
              color: "white"
              font {
                family: "JetBrainsMono Nerd Font"
                pixelSize: 15
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  service.clearNotifications()
                }
              }
            }
          }
        }

        Rectangle {
          Layout.fillWidth: true
          height: 1
          color: "#313244"
        }

        Item {
          Layout.fillWidth: true
          Layout.fillHeight: true

          visible: service.trackedNotifications.values.length === 0

          // Text {
          //   anchors.centerIn: parent
          //   text: "No Notifications"
          //   color: "white"
          //   horizontalAlignment: Text.AlignHCenter
          //   font {
          //     family: "Inter"
          //     pixelSize: 14
          //   }
          // }
        }

        ListView {
          id: notificationList

          Layout.fillWidth: true
          Layout.fillHeight: true

          model: service.trackedNotifications

          spacing: 8
          clip: true

          // visible: service.trackedNotifications.values.length > 0

          delegate: Rectangle {
            required property var modelData

            width: notificationList.width
            height: 80
            color: "#313244"
            radius: 5

            RowLayout {
              anchors.fill: parent
              anchors.margins: 5
              spacing: 10

              Image {
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                Layout.alignment: Qt.AlignVCenter

                source: modelData.image

                fillMode: Image.PreserveAspectCrop

                asynchronous: true
                mipmap: true

                sourceSize.width: 128
                sourceSize.height: 128

                visible: source !== ""
              }

              ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                spacing: 2

                Text {
                  Layout.fillWidth: true
                  text: modelData.appName
                  color: "#a6adc8"
                  font {
                    family: "Inter"
                    pixelSize: 10
                    bold: true
                  }
                  elide: Text.ElideRight
                }

                Text {
                  Layout.fillWidth: true
                  text: modelData.summary
                  color: "white"
                  font {
                    family: "Inter"
                    pixelSize: 12
                  }
                  maximumLineCount: 2
                  elide: Text.ElideRight
                }

                Text {
                  Layout.fillWidth: true
                  text: modelData.body
                  color: "#a6adc8"
                  font {
                    family: "Inter"
                    pixelSize: 10
                  }
                  maximumLineCount: 2
                  elide: Text.ElideRight
                }
              }
            }
          }
        }
      }
    }
  }

  PopupWindow {
    id: notificationToast
    anchor.item: root

    anchor.rect.x: 0
    anchor.rect.y: root.height + 5

    implicitWidth: 380
    implicitHeight: 100

    color: "transparent"
    visible: false

    Rectangle {
      anchors.fill: parent
      radius: 5
      color: "#1e1e2e"
      clip: true
      border {
        width: 1
        color: "#45475a"
      }

      RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Image {
          Layout.preferredWidth: 50
          Layout.preferredHeight: 50
          Layout.alignment: Qt.AlignVCenter

          source: notificationToast.notification ? notificationToast.notification.image : ""

          fillMode: Image.PreserveAspectCrop

          asynchronous: true
          mipmap: true

          sourceSize.width: 128
          sourceSize.height: 128

          visible: source !== ""
        }

        ColumnLayout {
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignVCenter

          spacing: 2

          Text {
            Layout.fillWidth: true
            text: notificationToast.notification ? notificationToast.notification.appName : ""
            color: "#a6adc8"
            font {
              family: "Inter"
              bold: true
              pixelSize: 10
            }
            elide: Text.ElideRight
          }

          Text {
            Layout.fillWidth: true
            text: notificationToast.notification ? notificationToast.notification.summary : ""
            color: "white"
            font {
              family: "Inter"
              pixelSize: 12
            }
            elide: Text.ElideRight
          }

          Text {
            Layout.fillWidth: true
            text: notificationToast.notification ? notificationToast.notification.body : ""
            color: "#a6adc8"
            font {
              family: "Inter"
              pixelSize: 10
            }
            elide: Text.ElideRight
          }
        }
      }
    }

    property var notification: null

    Timer {
      id: toastTimer

      interval: 5000
      repeat: false

      onTriggered: {
        notificationToast.visible = false
        notificationToast.notification = null
      }
    }
    
  }

  Connections {
    target: root.service

    function onNotificationReceived(notification) {
      if (root.service.dnd || !root.showToast)
        return

      notificationToast.notification = notification
      notificationToast.visible = true

      toastTimer.restart()
    }
  }
}
