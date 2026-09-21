// /bar/modules/notifications/NotificationPanel.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../../../"
import "../../../ui/"
import "../../../notifications/"

ColumnLayout {
    width:   parent?.width ?? 0
    spacing: 0

    TabMenu {
        Layout.fillWidth: true
        tabs: ["new", "read"]
        showDividers: true

        // new tab
        ColumnLayout {
            spacing: 4

            ScrollView {
                id:                     newScroll
                Layout.fillWidth:       true
                Layout.preferredHeight: Math.min(newList.implicitHeight, 320)
                clip:                   true
                contentWidth:           availableWidth

                Column { // new notifications
                    id:      newList
                    width:   newScroll.availableWidth
                    spacing: 4

                    Repeater {
                        model: NotificationService.newNotifs
                        delegate: NotificationCard {
                            width:        parent.width
                            compact:      true
                            notifId:      modelData.id
                            summary:      modelData.summary
                            body:         modelData.body
                            appName:      modelData.appName
                            desktopEntry: modelData.desktopEntry
                            onTapped:     NotificationService.markRead(notifId)
                        }
                    }

                    Text {
                        visible:             NotificationService.newNotifs.length === 0
                        width:               parent.width
                        text:                "no new notifications"
                        color:               Theme.colorSecondary
                        font.family:         Theme.fontFamily
                        font.pixelSize:      Theme.fontSmall
                        horizontalAlignment: Text.AlignHCenter
                        topPadding:          8
                        bottomPadding:       8
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                fillWidth:        true
                label:            "read all"
                labelSize:        Theme.fontSmall
                labelAlign:       Text.AlignHCenter
                onClicked:        NotificationService.markAllRead()
            }
        } // new tab

        // read tab
        ColumnLayout {
            spacing: 4

            ScrollView {
                id:                     readScroll
                Layout.fillWidth:       true
                Layout.preferredHeight: Math.min(readList.implicitHeight, 320)
                clip:                   true
                contentWidth:           availableWidth

                Column { // read notifications
                    id:      readList
                    width:   readScroll.availableWidth
                    spacing: 4

                    Repeater {
                        model: NotificationService.readNotifs
                        delegate: NotificationCard {
                            width:        parent.width
                            compact:      true
                            notifId:      modelData.id
                            summary:      modelData.summary
                            body:         modelData.body
                            appName:      modelData.appName
                            desktopEntry: modelData.desktopEntry
                            onTapped:     NotificationService.deleteRead(notifId)
                        }
                    }

                    Text {
                        visible:             NotificationService.readNotifs.length === 0
                        width:               parent.width
                        text:                "no read notifications"
                        color:               Theme.colorSecondary
                        font.family:         Theme.fontFamily
                        font.pixelSize:      Theme.fontSmall
                        horizontalAlignment: Text.AlignHCenter
                        topPadding:          8
                        bottomPadding:       8
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                fillWidth:        true
                label:            "clear all"
                labelSize:        Theme.fontSmall
                labelAlign:       Text.AlignHCenter
                onClicked:        NotificationService.clearRead()
            }
        } // read tab

    } // tabmenu

} // columnlayout
