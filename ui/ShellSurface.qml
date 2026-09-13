// ui/ShellSurface.qml
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

import "../"
import "../utils"

Scope {

    IpcHandler { // allows "qs -c ~/.config/quickshell/56os ipc call bar toggle" to work as a command & keybind
        target: "bar"
        function toggle(): void {
            if (PanelLogic.barVisible) PanelLogic.closeAll()
            PanelLogic.barVisible = !PanelLogic.barVisible
        }
        function show(): void { PanelLogic.barVisible = true  }
        function hide(): void { PanelLogic.barVisible = false }
    }

    Variants {
        model: Quickshell.screens
        delegate: Component {
            PanelWindow {
                id: surface
                required property var modelData

                screen: modelData
                color:  "transparent"

                anchors { top: true; left: true; right: true }
                margins { left: Theme.barMarginSide; right: Theme.barMarginSide }

                implicitHeight: screen.height

                WlrLayershell.layer:         WlrLayer.Top
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                readonly property var hyprMonitor: Utils.findMonitor( Hyprland.monitors?.values ?? [], screen.name )

                // should the bar be shown
                readonly property bool shouldShowBar: PanelLogic.barVisible && !(hyprMonitor?.activeWorkspace?.hasFullscreen ?? false)

                exclusiveZone: shouldShowBar ? Theme.barHeight : 0

                // input mask:
                // bar showing -> only bar strip is clickable
                // bar hidden  -> empty Region = no clickable area, all clicks pass through
                // panel open  -> full surface clickable so the PanelHost MouseArea can catch outside clicks
                Region { id: emptyRegion }
                Region { id: barRegion;  item: barContent }
                Region { id: fullRegion; item: surfaceFill }
                Item   { id: surfaceFill; anchors.fill: parent }

                BarContent {
                    id:        barContent
                    screen:    modelData
                    modelData: surface.modelData
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height:    Theme.barHeight
                    visible:   surface.shouldShowBar  //content hides, surface stays
                    opacity:   surface.shouldShowBar ? 1.0 : 0.0

                    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                }

                // bool checking whether a panel is currently open on this bar
                readonly property bool panelHere: PanelLogic.isOpen && PanelLogic.hostScreen?.name === modelData.name

                // update mask to account for panel open state
                mask: {
                    if (!shouldShowBar) return emptyRegion
                    if (panelHere)      return fullRegion
                    return barRegion
                }

                PanelHost {
                    anchors.fill: parent
                    screen:       modelData
                }


            } // panel window

        } // delegate component
    } // variants
} // scope
