import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
  id: root

  property string locationName: "Kannur"
  property real latitude: 11.8745
  property real longitude: 75.3704

  property var current: ({})
  property var daily: ({})
  property bool loaded: false
  property bool popupOpen: false

  implicitWidth: weatherRow.implicitWidth
  implicitHeight: 30

  function weatherIcon(code, isDay) {
    if (code === 0)
        return isDay ? "☀" : "☾"
    if (code === 1 || code === 2)
        return isDay ? "🌤" : "☁"
    if (code === 3)
        return "☁"
    if (code >= 45 && code <= 48)
        return "🌫"
    if (code >= 51 && code <= 67)
        return "🌧"
    if (code >= 71 && code <= 77)
        return "❄"
    if (code >= 80 && code <= 82)
        return "🌦"
    if (code >= 85 && code <= 86)
        return "🌨"
    if (code >= 95)
        return "⛈"

    return "🌡"
  }

  function weatherDescription(code) {
    if (code === 0) return "Clear sky"
    if (code === 1) return "Mainly clear"
    if (code === 2) return "Partly cloudy"
    if (code === 3) return "Overcast"
    if (code === 45 || code === 48) return "Foggy"
    if (code >= 51 && code <= 57) return "Drizzle"
    if (code >= 61 && code <= 67) return "Rain"
    if (code >= 71 && code <= 77) return "Snow"
    if (code >= 80 && code <= 82) return "Rain showers"
    if (code >= 85 && code <= 86) return "Snow showers"
    if (code >= 95) return "Thunderstorm"

    return "Current conditions"
  }

  Process {
    id: weatherProcess

    command: [
      "curl",
      "-fsS",
      "--max-time", "10",
      "https://api.open-meteo.com/v1/forecast?latitude=" +
        root.latitude +
        "&longitude=" +
        root.longitude +
        "&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,is_day" +
        "&daily=temperature_2m_max,temperature_2m_min" +
        "&timezone=Asia%2FKolkata&forecast_days=1"
    ]

    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const result = JSON.parse(text)

          root.current = result.current
          root.daily = result.daily
          root.loaded = true
        } catch (error) {
          console.error("Weather JSON error:", error)
        }
      }
    }

    onExited: (exitCode, exitStatus) => {
      if (exitCode !== 0) console.warn("Weather request failed:", exitCode)
    }
  }

  Timer {
    interval: 15 * 60 * 1000
    running: true
    repeat: true

    onTriggered: {
      if (!weatherProcess.running) weatherProcess.running = true
    }
  }

  RowLayout {
    id: weatherRow

    anchors.fill: parent
    spacing: 6

    Text {
      text: root.loaded ? root.weatherIcon( root.current.weather_code, root.current.is_day) : "◌"
      font.pixelSize: 17
      color: "#f4c95d"
    }

    Text {
      text: root.loaded ? Math.round(root.current.temperature_2m) + "°C" : "--°C"
      color: "#ffffff"
      font.family: "JetBrainsMono Nerd Font"
      font.pixelSize: 12
    }
  }

  MouseArea {
    anchors.fill: weatherRow
    cursorShape: Qt.PointingHandCursor
    onClicked: { 
      root.popupOpen = !root.popupOpen 
      weatherPopup.visible = !weatherPopup.visible
    }
  }

  PopupWindow {
    id: weatherPopup

    anchor.item: root
    anchor.rect.x: root.width / 2 - width / 2
    anchor.rect.y: root.height + 5

    implicitWidth: 280
    implicitHeight: 220

    color: "transparent"
    grabFocus: true

    Rectangle {
      anchors.fill: parent
      radius: 14
      color: "#191b22"
      border.width: 1
      border.color: "#343743"

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        RowLayout {
          Layout.fillWidth: true

          ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
              Layout.fillWidth: true
              text: root.locationName
              color: "#ffffff"
              font.pixelSize: 16
              font.bold: true
            }

            Text {
              Layout.fillWidth: true
              text: root.loaded ? root.weatherDescription( root.current.weather_code) : "Loading weather..."
              color: "#a6abb5"
              font.pixelSize: 11
            }
          }

          Rectangle {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            color: "transparent"
            Layout.alignment: Qt.AlignVCenter
            
            Text {
              anchors.centerIn: parent
              text: root.loaded ? root.weatherIcon( root.current.weather_code, root.current.is_day) : "◌"
              color: "white"
              font.pixelSize: 32
            }
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 12


          Text {
            text: root.loaded ? Math.round( root.current.temperature_2m) + "°" : "--°"

            color: "#ffffff"
            font.pixelSize: 38
            font.bold: true
          }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Text {
              text: root.loaded ? "Feels like " + Math.round( root.current.apparent_temperature) + "°C" : "Feels like --"
              color: "#d6d8df"
              font.pixelSize: 11
            }

            Text {
              text: root.loaded
                ? "H: " +
                  Math.round(
                    root.daily.temperature_2m_max[0]
                  ) + "°  L: " +
                  Math.round(
                    root.daily.temperature_2m_min[0]
                  ) + "°"
                : "H: --°  L: --°"

              color: "#a6abb5"
              font.pixelSize: 11
            }
          }
        }

        Rectangle {
          Layout.fillWidth: true
          height: 1
          color: "#343743"
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 8

          Rectangle {
            Layout.fillWidth: true
            height: 52
            radius: 9
            color: "#252832"

            Column {
              anchors.centerIn: parent
              spacing: 4

              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Humidity"
                color: "#a6abb5"
                font.pixelSize: 10
              }

              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.loaded
                  ? root.current.relative_humidity_2m + "%"
                  : "--"

                color: "#ffffff"
                font.pixelSize: 13
                font.bold: true
              }
            }
          }

          Rectangle {
            Layout.fillWidth: true
            height: 52
            radius: 9
            color: "#252832"

            Column {
              anchors.centerIn: parent
              spacing: 4

              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Wind"
                color: "#a6abb5"
                font.pixelSize: 10
              }

              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.loaded ? Math.round( root.current.wind_speed_10m) + " km/h" : "--"

                color: "#ffffff"
                font.pixelSize: 13
                font.bold: true
              }
            }
          }
        }
      }
    }
  }
}
