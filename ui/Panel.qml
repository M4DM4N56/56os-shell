// Panel.qml

import QtQuick
import Quickshell
import Quickshell.Wayland
import QtQuick.Shapes
import ".."

Scope {

    id: root

    required property var screen        // the screen the bar belongs to, passed from triggering module

    readonly property string side: {
        if (anchorWidth === 0) return "center"
        let pct = (anchorX - screen.x) / screen.width
        if (pct < 0.3) return "left"
        if (pct > 0.7) return "right"
        return "center"
    }

    property int panelWidth:    240     // default, changes based on call
    property bool isOpen:       false   // modules call these, never set isOpen directly

    property int anchorX:       0
    property int anchorWidth:   0

    default property alias content: contentItem.data

    function openPanel() {
        PanelLogic.open(root)
        isOpen = true
    }


    function closePanel() {
        isOpen = false
        if (PanelLogic.activePanel === root) { PanelLogic.activePanel = null }
    }
 

// positioning ---

    // where the panel would ideally sit (centered under anchor module)
    readonly property real barLeft:     Theme.barMarginSide
    readonly property real barRight:    screen.width - Theme.barMarginSide

    readonly property real panelLeft: {
        if (side === "center") return (screen.width - panelWidth) / 2

        if (side === "left") {
            let widgetLeft = (anchorX - screen.x) + Theme.barMarginSide
            if (widgetLeft - barLeft <= Theme.barPadding + 1) return barLeft
            return Math.min(barRight - panelWidth, widgetLeft)
        }

        if (side === "right") {
            let widgetRight = (anchorX - screen.x) + anchorWidth + Theme.barMarginSide
            if (barRight - widgetRight <= Theme.barPadding + 1) return barRight - panelWidth
            return Math.max(barLeft, widgetRight - panelWidth)
        }

        return barLeft
    }

    readonly property bool isAtEdge: {
        if (side === "left")  return panelLeft <= barLeft + 1
        if (side === "right") return panelLeft >= barRight - panelWidth - 1
        return false
    }
// --- positioning

// click outside catcher ---

    // a fullscreen transparent window on the overlay layer that sits behind panel
    // clicking anywhere that isnt the panel hits this catcher and closes the panel

    PanelWindow {
        screen:     root.screen
        visible:    root.isOpen
        color:      "transparent"

        anchors { top: true; bottom: true; left: true; right: true }

        // set as overlay and dont allow keyboard focus (shouldnt steal input from other windows)
        WlrLayershell.layer:         WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        MouseArea {
            anchors.fill: parent
            onClicked:    root.closePanel()
        }    
    } // panel window

// --- click outside catcher

// panel window ---
    PanelWindow {
        screen:     root.screen
        visible:    root.isOpen
        color:      "transparent"
        WlrLayershell.layer: WlrLayer.Overlay

        anchors { top: true; left: true }           // topleft positioning!
        margins { top: -Theme.barHeight; left: root.panelLeft }    // top is 0 to stick it to edge, anchored left to follow panelLeft

        implicitWidth: root.panelWidth
        implicitHeight: panelRect.naturalHeight

    // visual panel rectangle ---    
        Rectangle {
            id:    panelRect
            width: root.panelWidth
            color: Theme.colorBackground

            topLeftRadius:      0
            topRightRadius:     0
            bottomLeftRadius:   Theme.barRadius
            bottomRightRadius:  Theme.barRadius

            readonly property real naturalHeight: contentItem.implicitHeight + Theme.panelTopPadding + Theme.panelPadding

            clip:   true
            height: root.isOpen ? naturalHeight : 0

            Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutExpo } }

            Column {
                id:      contentItem
                x:       Theme.panelPadding
                y:       Theme.panelTopPadding
                width:   parent.width - Theme.panelPadding * 2
                spacing: Theme.moduleSpacing
            }

        } // rectangle
    // --- visual panel rectangle
       
    } // panel window


// --- panel window

    // left junction cap
    PanelWindow {
        screen:  root.screen
        visible: root.isOpen && !(side === "left" && isAtEdge)// flush panels dont need cap
        color:   "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        anchors { top: true; left: true }
        margins { top: 0; left: root.panelLeft - Theme.panelJoinRadius }
        implicitWidth:  Theme.panelJoinRadius
        implicitHeight: Theme.panelJoinRadius

        Shape {
            width:      Theme.panelJoinRadius
            height:     Theme.panelJoinRadius
            preferredRendererType: Shape.CurveRenderer

            // left cap
            ShapePath {
                id:         leftPath
                fillColor:  Theme.colorBackground
                strokeWidth: -1
                startX: 0; startY: 0
                
                PathArc {
                    x: leftPath.cr; y: leftPath.cr
                    radiusX: leftPath.cr; radiusY: leftPath.cr
                    direction: PathArc.Clockwise
                }
                PathLine { x: leftPath.cr; y: 0 }

                property real cr: Theme.panelJoinRadius
            } // shape path
        } // shape
    } // panel window

    // right junction cap
    PanelWindow {
        screen:  root.screen
        visible: root.isOpen && !(side === "right" && isAtEdge)
        color:   "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        anchors { top: true; left: true }
        margins { top: 0; left: root.panelLeft + root.panelWidth }

        implicitWidth:  Theme.panelJoinRadius
        implicitHeight: Theme.panelJoinRadius

        Shape {
            width:  Theme.panelJoinRadius
            height: Theme.panelJoinRadius
            preferredRendererType: Shape.CurveRenderer

            // right cap
            ShapePath {
                id:          rightPath
                fillColor:   Theme.colorBackground
                strokeWidth: -1

                startX: rightPath.cr; startY: 0
                PathArc {
                    x: 0; y: rightPath.cr
                    radiusX: rightPath.cr; radiusY: rightPath.cr
                    direction: PathArc.Counterclockwise
                }
                PathLine { x: 0; y: 0 }

                property real cr: Theme.panelJoinRadius
            } // shape path
        } // shape
    } // panel window

} // scope