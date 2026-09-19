// /bar/modules/notifications/NotificationWidget.qml
import QtQuick
import Quickshell
import "../../../"
import "../../../ui/"

Item {
    id: root

    required property var screen

    Component { id: notificationContent; NotificationPanel {} }

    implicitWidth:  notificationButton.implicitWidth
    implicitHeight: Theme.barHeight

    readonly property bool  hasUnread: NotificationService.hasUnread

    Button {
        id: notificationButton
        
        anchors.verticalCenter: parent.verticalCenter
        iconSource:             Qt.resolvedUrl("../../../assets/icons/notification/" + NotificationService.notificationIconName)
        implicitHeight:         parent.implicitHeight
        hoverInsetV:            3
        paddingH:               0
        iconSize:               Theme.mediumIconSize
        iconColor: !root.hasUnread ? Theme.colorSecondary : Theme.colorPrimary
        
        onClicked:              NotificationService.toggleDnd()
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: if (hovered) PanelLogic.open("notification", {
            owner:       root,
            content:     notificationContent,
            width:       Theme.notifPanelWidth,
            anchorX:     root.mapToGlobal(0, 0).x,
            anchorWidth: root.width,
            screen:      root.screen
        })
    }

} // item