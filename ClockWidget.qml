pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    implicitWidth: clockText.implicitWidth
    implicitHeight: clockText.implicitHeight

    SystemClock {
        id: clock

        precision: SystemClock.Seconds
    }

    Text {
        id: clockText

        anchors.fill: parent

        text: Qt.formatDateTime(clock.date, "    ddd,  MMM,  dd,  hh:mm:ss  AP")

        color: "white"

        font {
            pixelSize: 12
        }
    }

    PopupWindow {
        id: calendarPopup
        anchor.item: root
        anchor.rect.x: root.width / 2 - width / 2
        anchor.rect.y: root.height + 10
        implicitWidth: 300
        implicitHeight: 250
        color: 'transparent'

        Rectangle {
            anchors.fill: parent
            color: "black"
            radius: 5

            border {
                color: "#414868"
                width: 1
            }

            ColumnLayout {
                id: calender

                anchors.fill: parent
                anchors.topMargin: 5

                spacing: 5

                Label {
                    Layout.alignment: Qt.AlignHCenter

                    text: Qt.locale().monthName(clock.date.getMonth()) + " " + clock.date.getFullYear()

                    color: "white"

                    font {
                        pixelSize: 12
                        bold: true
                    }
                }

                DayOfWeekRow {
                    Layout.fillWidth: true

                    locale: Qt.locale()

                    delegate: Text {
                        required property var model

                        horizontalAlignment: Text.AlignHCenter

                        text: model.shortName

                        color: "#7aa2f7"
                    }
                }

                MonthGrid {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    month: clock.date.getMonth()
                    year: clock.date.getFullYear()

                    locale: Qt.locale()

                    delegate: Text {
                        required property var model

                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        text: model.day

                        color: model.today ? "#75f1fa" : "white"

                        opacity: model.month === clock.date.getMonth() ? 1 : 0.3

                        font {
                            pixelSize: 12
                            bold: model.today
                        }
                    }
                }
            }
        }
    }

    HoverHandler {
        onHoveredChanged: {
            calendarPopup.visible = hovered;
        }
    }
}
