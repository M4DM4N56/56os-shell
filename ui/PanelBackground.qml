// ui/PanelBackground.qml
import QtQuick
import QtQuick.Shapes
import ".."

Item {
    id: root

    property real  panelW:        240
    property real  panelH:        0
    property real  radius:        Theme.panelRadius
    property real  joinRadius:    Theme.panelJoinRadius
    property bool  capLeft:   true
    property bool  capRight:  true
    property color color:     Theme.colorBackground

    // cap grows from 0 as the panel extends downward, locks at joinRadius
    readonly property real effJoin: Math.min(joinRadius, panelH)

    // caps extend outside [0, panelW] — never clip
    clip: false

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor:   root.color
            strokeWidth: -1
            PathSvg { path: root.fullPath() }
        }
    }

    function fullPath() {
        var w = panelW
        var h = panelH
        var j = effJoin
        if (h <= 0.5) return "M 0 0 Z"

        var r = Math.min(radius, h / 2, w / 2)
        var d = ""

        if (capLeft && j > 0.5) {
            d += `M ${-j} 0 `
            d += `A ${j} ${j} 0 0 1 0 ${j} `
        } else {
            d += `M 0 0 `
        }

        d += `L 0 ${h - r} `
        d += `A ${r} ${r} 0 0 0 ${r} ${h} `
        d += `L ${w - r} ${h} `
        d += `A ${r} ${r} 0 0 0 ${w} ${h - r} `

        if (capRight && j > 0.5) {
            d += `L ${w} ${j} `
            d += `A ${j} ${j} 0 0 1 ${w + j} 0 `
        } else {
            d += `L ${w} 0 `
        }

        d += "Z"
        return d
    }
} // item
