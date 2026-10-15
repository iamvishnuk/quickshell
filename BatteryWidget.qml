import Quickshell
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts

RowLayout {
	id: root	

  Layout.preferredWidth: 10
  Layout.preferredHeight: 30

	property var battery: UPower.displayDevice
	property bool charging: battery.state === UPowerDeviceState.Charging
	readonly property int level: Math.round(battery.percentage * 100)

	readonly property string icon: {
		if (charging) return String.fromCodePoint(0xF0084)
		if (level >= 100) return String.fromCodePoint(0xF0079)
		if (level < 10) return String.fromCodePoint(0xF008B)

		return String.fromCodePoint(0xF007A + Math.floor(level / 10) - 1)
	}

	Text {
		Layout.alignment: Qt.AlignCenter

		text: root.icon
		color: root.charging ? "#7ad9a8" : root.level <= 15 ? "#ff5048" : root.level <=30 ? "#ffa478" : "#7ad9a8"

		font {
      family: "JetBrainsMono Nerd Font"
			pixelSize: 14
		}
	}

}
