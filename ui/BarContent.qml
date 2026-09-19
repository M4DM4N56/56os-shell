// ui/BarContent.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

import "../"
import "../bar/modules/clock"
import "../bar/modules/volume"
import "../bar/modules/media"
import "../bar/modules/workspace"
import "../bar/modules/notifications"

Item {
    id: root
    required property var screen
    required property var modelData

    property bool panelAtLeftEdge:  false
    property bool panelAtRightEdge: false
    
    readonly property bool hovered: barHover.hovered

    onPanelAtLeftEdgeChanged: {
        if (panelAtLeftEdge) { leftCornerAnim.stop();  barRect.bottomLeftRadius  = 0 }
        else                   leftCornerAnim.restart()
    }
    
    onPanelAtRightEdgeChanged: {
        if (panelAtRightEdge) { rightCornerAnim.stop(); barRect.bottomRightRadius = 0 }
        else                    rightCornerAnim.restart()
    }

    NumberAnimation { id: leftCornerAnim;  target: barRect; property: "bottomLeftRadius";  to: Theme.barRadius; duration: Theme.animFast; easing.type: Easing.OutCubic }
    NumberAnimation { id: rightCornerAnim; target: barRect; property: "bottomRightRadius"; to: Theme.barRadius; duration: Theme.animFast; easing.type: Easing.OutCubic }

    Rectangle {
        id:                barRect
        anchors.fill:      parent
        color:             Theme.colorBackground
        topLeftRadius:     0
        topRightRadius:    0
        bottomLeftRadius:  Theme.barRadius
        bottomRightRadius: Theme.barRadius

        HoverHandler { id: barHover }

        RowLayout { // left side
            anchors.left:           parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin:     Theme.barPadding
            spacing:                Theme.moduleSpacing

            ClockWidget         { screen: root.screen }
            WorkspaceWidget     { screen: root.screen }
            NotificationWidget  {screen: root.screen}
        }

        RowLayout { // center
            anchors.centerIn:       parent
            anchors.verticalCenter: parent.verticalCenter
            MediaWidget     { screen: root.screen }
        }

        RowLayout { // right side
            anchors.right:          parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin:    Theme.barPadding
            spacing:                Theme.moduleSpacing

            VolumeWidget    { screen: root.screen }
        }

    } // rectangle

} // item