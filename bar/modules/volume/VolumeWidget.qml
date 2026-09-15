// volumewidget.qml
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "../../../"
import "../../../ui/"

Item {
    id: root

    required property var screen

    Component { id: volumeContent; VolumePanel {} }

    implicitWidth:  volumeButton.implicitWidth
    implicitHeight: Theme.barHeight

    readonly property int   volumePct: AudioService.volumePct
    readonly property bool  muted: AudioService.muted

    Button {
        id: volumeButton

        anchors.verticalCenter: parent.verticalCenter
        iconSource:     Qt.resolvedUrl("../../../assets/icons/volume/" + AudioService.volumeIconName)
        label:          root.muted ? "———": root.volumePct < 10 ? root.volumePct + " %": root.volumePct + "%"
        labelWeight:    Font.DemiBold
        implicitHeight: parent.implicitHeight
        hoverInsetV:    3
        labelColor:     root.muted ? Theme.colorSecondary : Theme.colorPrimary
        iconColor:      root.muted ? Theme.colorSecondary : Theme.colorPrimary
        onClicked:      AudioService.toggleMute()
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: if (hovered) PanelLogic.open("volume", {
            owner:       root,
            content:     volumeContent,
            width:       Theme.volumePanelWidth,
            anchorX:     root.mapToGlobal(0, 0).x,
            anchorWidth: root.width,
            screen:      root.screen
        })
    }

} // item