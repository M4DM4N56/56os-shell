// ui/PanelHost.qml

// handles panel positioning and click outside logic 
// calls PanelReveal for animations
// calls PanelBackground for spawning panel background
// loads panel contents at the same place the panel background spawns

import QtQuick
import ".."

Item {
    id: host
    required property var screen

    readonly property bool active: PanelLogic.isOpen && PanelLogic.hostScreen?.name === screen.name


// positioning ---
    readonly property real barLeft:  0
    readonly property real barRight: host.width     // surface width

    // widget position in surface coordinates
    readonly property real widgetSurfaceX: PanelLogic.anchorX - screen.x

    // designate side for panel based on where widget is on bar
    readonly property string side: {
        if (PanelLogic.anchorWidth === 0) return "center"
        let pct = (PanelLogic.anchorX - screen.x) / screen.width
        if (pct < 0.3) return "left"
        if (pct > 0.7) return "right"
        return "center"
    }

    // find where the left-x of panel should be placed given the panel width and panel side
    readonly property real panelLeft: {
        let w = PanelLogic.requestedWidth
        if (side === "center") return (host.width - w) / 2
        if (side === "left") {
            let wl = widgetSurfaceX
            if (wl - barLeft <= Theme.barPadding + 1) return barLeft // if leftmost widget spawn, make panel left-aligned
            return Math.min(barRight - w, wl)
        }
        if (side === "right") {
            let wr = widgetSurfaceX + PanelLogic.anchorWidth
            if (barRight - wr <= Theme.barPadding + 1) return barRight - w // same but for right side
            return Math.max(barLeft, wr - w)
        }
        return barLeft
    }


    readonly property bool isAtEdge: {
        if (side === "left")  return panelLeft <= barLeft + 1
        if (side === "right") return panelLeft + PanelLogic.requestedWidth >= barRight - 1
        return false
    }
// --- positioning


    // instantiate animation engine
    PanelReveal {
        id: reveal
        open: host.active
    }

    MouseArea {
        anchors.fill: parent
        enabled:      reveal.progress > 0
        onClicked:    PanelLogic.close()
    }

// panel item ---

    // the panel starts at the very top of the surface andslides downward
    // content is anchored to the top and flows downward
    // content begins where the widget was
    // the junction caps are drawn at barHeight where the panel necks out
    Item {
        id: panel

        x:     host.panelLeft
        width: PanelLogic.requestedWidth
        y:     0
        clip:  false   // caps are drawn outside our box — don't clip them

        readonly property real naturalHeight:
            contentLoader.implicitHeight + Theme.panelTopPadding + Theme.panelPadding

        height: reveal.progress * naturalHeight

        // morph animations 
        // x and width glide only when swapping between open panels while one is already open
        // only works when a panel is fully open (progress > 0.99)
        Behavior on x     { enabled: reveal.progress > 0.99; NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
        Behavior on width { enabled: reveal.progress > 0.99; NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

        // values taken directly from panelLogic, or derived from reveal, theme, etc.
        PanelBackground {
            anchors.fill: parent
            panelW:    panel.width
            panelH:    panel.height
            barHeight: Theme.barHeight
            capLeft:   !(host.side === "left"  && host.isAtEdge)
            capRight:  !(host.side === "right" && host.isAtEdge)
        }

        // content loader
        Item {
            anchors.fill: parent
            clip: true

            Loader {
                id: contentLoader

                x:     Theme.panelPadding
                width: panel.width - Theme.panelPadding * 2
                y:     Theme.panelTopPadding

                // keep content loaded during close animation so it doesn't pop out
                sourceComponent: (host.active || reveal.progress > 0.01)
                    ? PanelLogic.content
                    : null
            }
        } // item

    } // item
// --- panel item

} // item