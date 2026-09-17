// bar/modules/TestWidget.qml
import QtQuick
import Quickshell
import "../../.."
import "../../../ui"

Item {
    id: root
    required property var screen

    readonly property bool panelOpen: PanelLogic.owner === root

    implicitWidth:  label.implicitWidth + 16
    implicitHeight: Theme.barHeight

    Component {
        id: testContent
        Text {
            text:           "panel is working"
            color:          Theme.colorPrimary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontBase
        }
    }

    Text {
        id:               label
        anchors.centerIn: parent
        text:             root.panelOpen ? "▼ test" : "▲ test"
        color:            Theme.colorPrimary
        font.family:      Theme.fontFamily
        font.pixelSize:   Theme.fontBase
        font.weight:      Font.DemiBold
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: if (hovered) PanelLogic.open("test", {
            owner:       root,
            content:     testContent,
            width:       200,
            anchorX:     root.mapToGlobal(0, 0).x,
            anchorWidth: root.width,
            screen:      root.screen
        })
    }
}
