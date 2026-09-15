// ui/ShellSurface.qml
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

import "../"
import "../utils"

Scope {

    IpcHandler {
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

                readonly property bool shouldShowBar: PanelLogic.barVisible && !(hyprMonitor?.activeWorkspace?.hasFullscreen ?? false)

                exclusiveZone: shouldShowBar ? Theme.barHeight : 0

                // mask covers bar strip + animated panel height; shrinks to bar-only when no panel
                Region { id: emptyRegion }
                Item {
                    id: hoverMaskItem
                    x: 0; y: 0
                    width:  parent.width
                    height: Theme.barHeight + panelHost.panelVisibleHeight
                }
                Region { id: hoverRegion; item: hoverMaskItem }

                mask: shouldShowBar ? hoverRegion : emptyRegion

                PanelHost {
                    id:           panelHost
                    anchors.fill: parent
                    screen:       modelData
                    barHovered:   barContent.hovered
                }

                BarContent {
                    id:        barContent
                    screen:    modelData
                    modelData: surface.modelData
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height:    Theme.barHeight
                    visible:   surface.shouldShowBar
                    opacity:   surface.shouldShowBar ? 1.0 : 0.0

                    panelAtLeftEdge:  panelHost.revealProgress > 0 && panelHost.isAtLeftEdge
                    panelAtRightEdge: panelHost.revealProgress > 0 && panelHost.isAtRightEdge

                    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                }

            } // panel window
        } // delegate component
    } // variants
} // scope
