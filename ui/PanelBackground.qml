// ui/PanelBackground.qml
import QtQuick
import QtQuick.Shapes
import ".."

Item {
    id: root

    property real  panelW:     240
    property real  panelH:     0            // live (animated) height, from panel top
    property real  barHeight:  0            // where the panel necks out of the bar
    property real  radius:     Theme.panelJoinRadius
    property real  joinRadius: Theme.panelJoinRadius
    property bool  capLeft:    true
    property bool  capRight:   true
    property color color:      Theme.colorBackground

    // cap radius grows from 0 as the panel emerges below the bar, then locks
    // to joinRadius. no cap until the panel has cleared the bar.
    readonly property real effJoin: Math.max(0, Math.min(joinRadius, panelH - barHeight))

    // caps are drawn outside our [0,panelW] box — never clip
    clip: false

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        // panel body: square top (sits over the bar), rounded bottom corners
        ShapePath {
            fillColor:   root.color
            strokeWidth: -1
            PathSvg { path: root.bodyPath() }
        }

        // junction caps: concave fillets at barHeight on the non-flush sides
        ShapePath {
            fillColor:   root.color
            strokeWidth: -1
            PathSvg { path: root.capsPath() }
        }
    }

    function bodyPath() {
        var w = panelW
        var h = panelH
        if (h <= 0.5) return "M 0 0 Z"

        var r = Math.min(radius, h / 2, w / 2)

        var d = "M 0 0 "
        d += `L 0 ${h - r} `
        d += `A ${r} ${r} 0 0 0 ${r} ${h} `       // bottom-left  convex
        d += `L ${w - r} ${h} `
        d += `A ${r} ${r} 0 0 0 ${w} ${h - r} `   // bottom-right convex
        d += `L ${w} 0 `
        d += "Z"
        return d
    }

    function capsPath() {
        var w  = panelW
        var bh = barHeight
        var j  = effJoin
        if (j <= 0.5) return "M 0 0 Z"

        var d = ""

        // left fillet: curves from the bar bottom down into the panel's left side
        if (capLeft) {
            d += `M ${-j} ${bh} `
            d += `A ${j} ${j} 0 0 1 0 ${bh + j} `
            d += `L 0 ${bh} `
            d += "Z "
        }

        // right fillet: mirror of the left
        if (capRight) {
            d += `M ${w + j} ${bh} `
            d += `A ${j} ${j} 0 0 0 ${w} ${bh + j} `
            d += `L ${w} ${bh} `
            d += "Z "
        }

        return d === "" ? "M 0 0 Z" : d
    }
} // item
