import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
  id: root

  anchors.fill: parent

  color: "transparent"
  radius: 5
  
  border {
    color: "#414868"
    width: 1
  }

  property string wallpaperDir: Quickshell.env("HOME") + "/.config/quickshell/assets/wallpapers"

  ListModel {
    id: wallpaperModel
  }

  Process {
    id: scanWallpapers
    running: true

    command: [
      "sh", "-c",
      "find \"$1\" -maxdepth 1 -type f " +
      "\\( -iname '*.jpg' -o -iname '*.jpeg' " +
      "-o -iname '*.png' -o -iname '*.webp' " +
      "-o -iname '*.avif' \\) -print | sort",
      "wallpaper-selector",
      root.wallpaperDir
    ]

    stdout: StdioCollector {
      onStreamFinished: {
        wallpaperModel.clear()

        const output = text.trim()

        if (!output) return

        for (const path of output.split("\n")) {
          wallpaperModel.append({
            path: path,
            name: path.split("/").pop()
          })
        }
      }
    }
  }

  Process {
    id: applyWallpaper
  }

  GridView {
    id: wallpaperGallery

    anchors.fill: parent
    anchors.margins: 10

    clip: true
    cellWidth: ( root.width / 2 ) - 10
    cellHeight: 180
    model: wallpaperModel

    ScrollBar.vertical: ScrollBar {}

    delegate: Item {
      id: tile

      required property string path
      required property string name

      property bool hovered: false

      width: wallpaperGallery.cellWidth
      height: wallpaperGallery.cellHeight

      Rectangle {
        id: card
        anchors.fill: parent
        anchors.margins: 10
        radius: 5
        color: "transparent"
        clip: true

        scale: tile.hovered ? 1.025 : 1

        Behavior on scale {
          NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
          }
        }

        Image {
          anchors.fill: parent
          source: "file://" + tile.path
          fillMode: Image.PreserveAspectCrop

          asynchronous: true
          cache: true
        }

        Rectangle {
          anchors.fill: parent
          color: "transparent"
          radius: 5
          border {
            color: "#414868"
            width: 1
          }

        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onEntered: tile.hovered = true
          onExited: tile.hovered = false
          cursorShape: Qt.PointingHandCursor

          onClicked: {
            applyWallpaper.command = [
                "awww", "img", tile.path,
                "--transition-type", "grow",
                "--transition-duration", "1"
            ]
            applyWallpaper.running = true
          }
        }
      }
    }
  }

}
