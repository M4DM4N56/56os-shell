// volumewidget.qml
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Pipewire
import "../../../"
import "../../../ui/"

Item {
    id: root
    
    required property var screen

    Component { id: volumeContent; VolumePanel {} }

    // this specific instance owns the open panel
    readonly property bool panelOpen: PanelLogic.owner === root

    implicitWidth: panelOpen
        ? Theme.volumePanelWidth
        : Theme.iconSize + (Theme.modulePadding * 2) + 16

    opacity: panelOpen ? 0.0 : 1.0

    Behavior on implicitWidth {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    implicitHeight: Theme.barHeight

    readonly property int   volumePct: AudioService.volumePct
    readonly property bool  muted: AudioService.muted

    Row {
        anchors.right:          parent.right
        anchors.rightMargin:    0
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4
        
        ColoredIcon {
            anchors.verticalCenter: parent.verticalCenter
            
            source: Qt.resolvedUrl("../../../assets/icons/volume/" + AudioService.volumeIconName)
            color: Theme.colorPrimary
        }

        Text {
            text:           root.muted ? "———": root.volumePct < 10 ? root.volumePct + " %": root.volumePct + "%"
            color:          Theme.colorPrimary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontBase
            font.weight:    Font.DemiBold
        }
    } // row

    MouseArea {
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
        onClicked: {
            PanelLogic.toggle("volume", {
                owner:       root,
                content:     volumeContent,
                width:       Theme.volumePanelWidth,
                anchorX:     root.mapToGlobal(0, 0).x,
                anchorWidth: root.width,
                screen:      root.screen
            })
        }
    }

} // item