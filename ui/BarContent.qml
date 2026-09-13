// ui/BarContent.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

import "../"
import "../bar/modules/"
import "../bar/modules/volume"
import "../bar/modules/media"

Item {
    id: root
    required property var screen
    required property var modelData

    Rectangle {
        anchors.fill:  parent
        color:         Theme.colorBackground
        topLeftRadius:  0
        topRightRadius: 0
        radius:         Theme.barRadius

        RowLayout { // left side
            anchors.left:           parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin:     Theme.barPadding
            spacing:                Theme.moduleSpacing

            ClockWidget {}
            WorkspaceIndicator { screen: root.screen }
        }

        RowLayout { // center
            anchors.centerIn:       parent
            anchors.verticalCenter: parent.verticalCenter
            MediaWidget { screen: root.screen }
        }

        RowLayout { // right side
            anchors.right:          parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin:    Theme.barPadding
            spacing:                Theme.moduleSpacing

            VolumeWidget { screen: root.screen }
            VolumeWidget { screen: root.screen }
            VolumeWidget { screen: root.screen }
        }

    } // rectangle

} // item