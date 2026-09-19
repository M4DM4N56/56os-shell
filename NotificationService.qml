// ./NotificationService.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    // initialize notif server to receive D-Bus notifications
    NotificationServer {
        keepOnReload:   false
        bodySupported:  true
        imageSupported: true
        onNotification: (notif) => root.receive(notif)
    }

    property bool dndEnabled: false

    property var newNotifs:  []
    property var readNotifs: []

    ListModel { id: popupModel } // listmodel has better insert/remove capabilities than array
    property alias popupQueue: popupModel // subset of new notifications, only notifications currently shown as toasts

    // maps notifId -> expiry timestamp
    property var expiry: ({})

    // emitted when notif timer expires NotificationPopup triggers dismiss animation before removing the delegate
    signal shouldDismiss(var notifId)

    readonly property int  unreadCount: newNotifs.length
    readonly property bool hasUnread:   newNotifs.length > 0

    readonly property string notificationIconName: {
        if (dndEnabled)          return "notification-slash.svg"
        if (newNotifs.length > 0) return "notification-ping.svg"
        return "notification-empty.svg"
    }

    // pinged every 250 ms while popups are active
    Timer {
        interval: 250
        repeat:   true
        running:  popupModel.count > 0
        onTriggered: {
            const now = Date.now()
            for (let i = 0; i < popupModel.count; i++) {
                const id  = popupModel.get(i).notifId
                const exp = root.expiry[id]
                if (exp !== undefined && now >= exp) {
                    delete root.expiry[id]  // remove before signalling to avoid double-fire
                    root.shouldDismiss(id)
                }
            }
        }
    } // timer

    // snapshot is appended to newNotifs always; also queued as a toast unless DnD is on
    function receive(notif) {
        if (!notif) return
        const snap = { // create snapshot with whatever info is given
            id:           notif.id,
            summary:      notif.summary      || "",
            body:         notif.body         || "",
            appName:      notif.appName      || "",
            desktopEntry: notif.desktopEntry || notif.appName || ""
        }
        newNotifs = [snap, ...newNotifs]
        if (dndEnabled) { newNotifsChanged(); return }
        popupModel.append({
            notifId:      snap.id,
            summary:      snap.summary,
            body:         snap.body,
            appName:      snap.appName,
            desktopEntry: snap.desktopEntry
        })
        expiry[snap.id] = Date.now() + 5000
    }

    // hovering a toast removes its expiry entry, unhovering sets another 5-second window
    function hoverEnter(notifId) { delete expiry[notifId] }
    function hoverExit(notifId)  { expiry[notifId] = Date.now() + 5000 }

    // move notification from newNotifs to readNotifs, called when the user clicks eye button
    function markRead(notifId) {
        const notif = newNotifs.find(n => n.id === notifId)
        if (notif) {
            newNotifs  = newNotifs.filter(n => n.id !== notifId)
            readNotifs = [notif, ...readNotifs]
        }
    }

    function markAllRead() {
        readNotifs = [...newNotifs, ...readNotifs]
        newNotifs  = []
    }

    function deleteRead(notifId) { readNotifs = readNotifs.filter(n => n.id !== notifId) }
    function toggleDnd() { dndEnabled = !dndEnabled }
    function clearRead() { readNotifs = [] }

    // removes notification from popup listmodel after its dismiss animation finishes
    // called by notificationpopup per-delegate only
    function removeFromQueue(notifId) {
        for (let i = 0; i < popupModel.count; i++) {
            if (popupModel.get(i).notifId === notifId) {
                popupModel.remove(i)
                delete expiry[notifId]
                return
            }
        }
    }


} // singleton