// ui/PanelHost.qml
import QtQuick
import ".."

Item {
    id: host
    required property var screen

    property bool barHovered: false   // set by ShellSurface from BarContent.hovered

    readonly property bool active: PanelLogic.isOpen && PanelLogic.hostScreen?.name === screen.name


// positioning ---
    readonly property real barLeft:  0
    readonly property real barRight: host.width

    readonly property real widgetSurfaceX: PanelLogic.anchorX - screen.x

    // widget is flush with the bars left or right edge (within barPadding tolerance)
    readonly property bool isAtLeftEdge:  widgetSurfaceX <= barLeft + Theme.barPadding + 1
    readonly property bool isAtRightEdge: widgetSurfaceX + PanelLogic.anchorWidth >= barRight - Theme.barPadding - 1
    readonly property bool isAtEdge:      isAtLeftEdge || isAtRightEdge

    // center panel under widget, then clamp to barEdgeSpace from each edge
    // if the widget is flush with a bar edge, snap the panel fully to that edge
    readonly property real panelLeft: {
        let w  = PanelLogic.requestedWidth
        let nl = widgetSurfaceX + PanelLogic.anchorWidth / 2 - w / 2

        if (nl < Theme.barEdgeSpace)
            return isAtLeftEdge ? barLeft : Theme.barEdgeSpace

        if (nl + w > barRight - Theme.barEdgeSpace)
            return isAtRightEdge ? barRight - w : barRight - w - Theme.barEdgeSpace

        return nl
    }
// --- positioning


    PanelReveal {
        id: reveal
        open: host.active
    }

    readonly property real revealProgress:    reveal.progress
    readonly property real panelVisibleHeight: panel.height

    // close when pointer leaves both the bar and the panel
    readonly property bool inHoverZone: host.barHovered || panelHover.hovered
    onInHoverZoneChanged: inHoverZone ? closeTimer.stop() : closeTimer.start()

    Timer {
        id: closeTimer
        interval: 100
        onTriggered: PanelLogic.close()
    }


// panel item ---
    Item {
        id: panel

        x:     host.panelLeft
        width: PanelLogic.requestedWidth
        y:     Theme.barHeight
        clip:  false

        readonly property real naturalHeight: contentLoader.implicitHeight + Theme.panelPaddingV

        height: reveal.progress * naturalHeight

        // panel animation morphs
        Behavior on x     { enabled: reveal.progress > 0.99; NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
        Behavior on width { enabled: reveal.progress > 0.99; NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

        HoverHandler { id: panelHover }

        PanelBackground {
            anchors.fill: parent
            panelW:   panel.width
            panelH:   panel.height
            capLeft:  !host.isAtLeftEdge
            capRight: !host.isAtRightEdge
        }

        Item {
            anchors.fill: parent
            clip: true

            Loader {
                id: contentLoader

                x:     Theme.panelPaddingH
                width: panel.width - Theme.panelPaddingH * 2
                y:     0 //Theme.panelTopPadding

                sourceComponent: (host.active || reveal.progress > 0.01)
                    ? PanelLogic.content
                    : null
            }
        }

    } // panel item
// --- panel item

} // item