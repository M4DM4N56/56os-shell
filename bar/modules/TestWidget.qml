// bar/modules/TestWidget.qml
import QtQuick
import Quickshell
import "../.."
import "../../ui"

Item {
    id: root
    required property var screen

    implicitWidth:  label.implicitWidth + 16
    implicitHeight: Theme.barHeight

    Text {
        id:                 label
        anchors.centerIn:   parent
        text:               panel.isOpen ? "▼ test" : "▲ test"
        color:              Theme.colorPrimary
        font.family:        Theme.fontFamily
        font.pixelSize:     Theme.fontBase
        font.weight:        Font.DemiBold 
    }

    MouseArea {
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
        onClicked: {
            if (panel.isOpen) { panel.closePanel() } 
            else {
                panel.anchorX     = root.mapToGlobal(0, 0).x
                panel.anchorWidth = root.width
                panel.openPanel()
            }
        }
    }

    Panel {
        id:         panel
        screen:     root.screen
        panelWidth: 200

        Text {
            text:           "panel is working"
            color:          Theme.colorPrimary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontBase
        }
    }
}