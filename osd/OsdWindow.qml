// osd/OsdWindow.qml

import QtQuick
import Quickshell
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Hyprland
import ".."
import "../ui/"
import "../utils/"

Scope {
    Variants {

        model: Quickshell.screens
        delegate: Component {

            PanelWindow {

                property bool dismissing: false
                required property var modelData

                readonly property var hyprMonitor: Utils.findMonitor(Hyprland.monitors?.values ?? [], modelData.name)
                readonly property bool monitorObscured:   hyprMonitor?.activeWorkspace?.hasFullscreen ?? false
                readonly property bool barHiddenHere:     !PanelLogic.barVisible || monitorObscured

                // watch for dismiss, start exit animation, hide window after it finishes
                Connections {
                    target: Osd
                    function onShowingChanged() {
                        if (!Osd.showing) {
                            dismissing = true
                            dismissTimer.start()
                        }
                    }
                }

                Timer {
                    id:             dismissTimer
                    interval:       260
                    onTriggered:    parent.dismissing = false
                }

                screen:                         modelData
                color:                          "transparent"
                anchors                         { top: true; left: true; right: true }
                implicitHeight:                 osdRect.height
                visible:                        (Osd.showing || dismissing) && barHiddenHere
                WlrLayershell.layer:            WlrLayer.Overlay
                WlrLayershell.keyboardFocus:    WlrKeyboardFocus.None
                exclusionMode:                  ExclusionMode.Ignore

                Rectangle {
                    id: osdRect
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    color:             Theme.colorBackground
                    topLeftRadius:     0
                    topRightRadius:    0
                    bottomLeftRadius:  Theme.barRadius
                    bottomRightRadius: Theme.barRadius

                    height: Theme.barHeight
                    width: Math.min( osdContent.implicitWidth + Theme.panelPaddingH * 2, Theme.osdMaxWidth )
                    Behavior on width { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

                    // hidden: translate upward off screen
                    // showing: back to y=0
                    property real slideY: Osd.showing ? 0 : -height
                    transform: Translate { y: osdRect.slideY }
                    Behavior on slideY { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                    Row {
                        id:                 osdContent
                        anchors.centerIn:   parent
                        spacing:            6

                        ColoredIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            source: (Osd.showing && Osd.icon.toString() !== "") ? Qt.resolvedUrl("../assets/icons/" + Osd.icon) : ""
                            visible: Osd.icon.toString() !== ""
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:           Osd.text
                            color:          Theme.colorPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontBase
                            font.weight:    Font.DemiBold
                            width:          Math.min( implicitWidth, Theme.osdMaxWidth - Theme.panelPaddingH * 2 )
                            elide:          Text.ElideRight
                        }
                    } // row

                } // rectangle

            } // panel window
        } // component

    } // variants
} // scope