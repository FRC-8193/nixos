pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Notification daemon: popups (temporary) + history (shown in the right sidebar).
Singleton {
  id: root

  property bool dnd: false
  property alias history: historyModel
  property alias popups: popupModel

  ListModel { id: historyModel }
  ListModel { id: popupModel }

  NotificationServer {
    keepOnReload: true
    bodySupported: true
    imageSupported: true
    onNotification: n => {
      n.tracked = true
      const item = { nid: n.id, app: n.appName, summary: n.summary, body: n.body }
      historyModel.insert(0, item)
      if (!root.dnd) popupModel.append(item)
    }
  }

  function dismissPopup(nid) {
    for (let i = 0; i < popupModel.count; i++) {
      if (popupModel.get(i).nid === nid) { popupModel.remove(i); return }
    }
  }
  function clearAll() { historyModel.clear(); popupModel.clear() }
}
