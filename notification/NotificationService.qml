import Quickshell.Services.Notifications
import QtQuick

Item {
  id: root

  property bool dnd: false
  property int dndDuration: 0

  readonly property var trackedNotifications: notificationServer.trackedNotifications
  signal notificationReceived(var notification)

  function enableDnd(minutes) {
    root.dnd = true
    root.dndDuration = minutes

    if (minutes > 0)
      dndTimer.restart()
    else
      dndTimer.stop()
  }

  function disableDnd() {
    root.dnd = false
    root.dndDuration = 0
    dndTimer.stop()
  }

  function toggleDnd() {
    if (root.dnd)
      disableDnd()
    else
      enableDnd(0)
  }

  function clearNotifications() {
    const notifications =[...notificationServer.trackedNotifications.values]

    for (const notification of notifications)
      notification.dismiss()
  }

  Timer {
    id: dndTimer

    interval: root.dndDuration * 60 * 1000
    repeat: false

    onTriggered: {
      root.dnd = false
      root.dndDuration = 0
    }
  }

  NotificationServer {
    id: notificationServer

    bodySupported: true
    imageSupported: true
    actionsSupported: true

    onNotification: notification => {
      notification.tracked = true
      root.notificationReceived(notification)
    }
  }
}
