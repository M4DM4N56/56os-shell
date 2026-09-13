// OsdWindow.qml

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

                readonly property var hyprMonitor: Utils.findMonitor(
                    Hyprland.monitors?.values ?? [], modelData.name)
                    
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
                    id:       dismissTimer
                    interval: 260   // slightly longer than slideY animation duration
                    onTriggered: parent.dismissing = false
                }

                screen:         modelData
                color:          "transparent"
                anchors { top: true; left: true; right: true }
                implicitHeight: Theme.barHeight
                visible: (Osd.showing || dismissing) && barHiddenHere
                WlrLayershell.layer:         WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                exclusionMode: ExclusionMode.Ignore

                Rectangle {
                    id:                       osdRect
                    width:                    Theme.osdSimpleWidth
                    height:                   Theme.barHeight
                    anchors.horizontalCenter: parent.horizontalCenter
                    // y defaults to 0 — top of screen, where we want it when showing

                    color:             Theme.colorBackground
                    topLeftRadius:     0
                    topRightRadius:    0
                    bottomLeftRadius:  Theme.barRadius
                    bottomRightRadius: Theme.barRadius

                    // hidden: translate upward off screen
                    // showing: back to y=0
                    property real slideY: Osd.showing ? 0 : -height
                    Behavior on slideY {
                        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }

                    transform: Translate { y: osdRect.slideY }

                    Row {
                        anchors.centerIn: parent
                        spacing:          6
                        visible:          Osd.osdType === "simple"

                        Item {
                            width:  Theme.iconSize
                            height: Theme.iconSize
                            anchors.verticalCenter: parent.verticalCenter

                            ColoredIcon {
                                source: Osd.showing
                                    ? Qt.resolvedUrl("../assets/icons/" + Osd.simpleIcon)
                                    : ""
                                color: Theme.colorPrimary
                            }
                        }


                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:           Osd.simpleValue
                            color:          Theme.colorPrimary
                            font.family:    Theme.fontFamily
                            font.pixelSize: Theme.fontBase
                            font.weight:    Font.DemiBold
                        }
                    }
                }
            }
        } // component

    } // variants

} // scope