// ./notifications/NotificationPopup.qml

import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

Scope {
    Variants {
        model: Quickshell.screens
        delegate: Component {

            PanelWindow {
                required property var modelData

                screen:  modelData
                color:   "transparent"
                anchors  { top: true; right: true }
                margins  { top: Theme.barMarginSide }

                // width includes barMarginSide so the card can slide in from off-screen
                implicitWidth:  Theme.notifToastWidth + Theme.barMarginSide
                implicitHeight: Math.max(notifRepeater.count, 1) * 160

                visible: NotificationService.popupQueue.count > 0

                Item   { id: maskArea; x: 0; y: 0; width: Theme.notifToastWidth; height: parent.height }
                Region { id: activeMask; item: maskArea }
                Region { id: emptyMask }
                mask: NotificationService.popupQueue.count > 0 ? activeMask : emptyMask

                WlrLayershell.layer:         WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                WlrLayershell.exclusiveZone: 0

                Column {
                    x: 0; y: 0
                    width:   parent.width
                    spacing: 0

                    Repeater {
                        id:    notifRepeater
                        model: NotificationService.popupQueue

                        delegate: Item {
                            id:    delegateRoot
                            width: parent.width

                            property bool showing:   false
                            property bool collapsed: false

                            implicitHeight: collapsed ? 0 : (card.implicitHeight + 8)
                            Behavior on implicitHeight { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

                            Component.onCompleted: showing = true

                            HoverHandler {
                                onHoveredChanged: hovered
                                    ? NotificationService.hoverEnter(model.notifId)
                                    : NotificationService.hoverExit(model.notifId)
                                cursorShape: Qt.PointingHandCursor
                            }

                            TapHandler { onTapped: delegateRoot.startDismiss() }

                            function startDismiss() {
                                showing   = false
                                collapsed = true
                                removeTimer.start()
                            }

                            Connections {
                                target: NotificationService
                                function onShouldDismiss(id) {
                                    if (id === model.notifId) delegateRoot.startDismiss()
                                }
                            }

                            Timer {
                                id:          removeTimer
                                interval:    Theme.animFast
                                onTriggered: NotificationService.removeFromQueue(model.notifId)
                            }

                            NotificationCard {
                                id:           card
                                notifId:      model.notifId
                                summary:      model.summary
                                body:         model.body
                                appName:      model.appName
                                desktopEntry: model.desktopEntry

                                // slide in/out from the right edge of the window
                                x: delegateRoot.showing ? 0 : Theme.notifToastWidth + Theme.barMarginSide
                                Behavior on x { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

                                onMarkRead: {
                                    NotificationService.markRead(model.notifId)
                                    delegateRoot.startDismiss()
                                }
                            }

                        } // item
                    } // repeater
                } // column
            } // panel window
        } // delegate component
    } // variants
} // scope
