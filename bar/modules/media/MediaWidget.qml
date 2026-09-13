// bar/modules/media/MediaWidget.qml
import QtQuick
import QtQuick.Effects
import Quickshell
import "../../.."       // access to singletons
import "../../../ui/"   // for panel popup and icons


Item {
    id: root

    required property var screen

    readonly property bool panelOpen: PanelLogic.owner === root

    Component { id: mediaContent; MediaPanel {} }

    implicitWidth: panelOpen
        ? Theme.mediaPanelWidth // panel is open: change widget width to panel width
        : MediaService.hasMedia
            ? row.implicitWidth + (Theme.modulePadding * 2) // panel isnt open: give the widget its proper width
            : 0

    implicitHeight: Theme.barHeight

    opacity: (panelOpen || !MediaService.hasMedia) ? 0.0 : 1.0

    Behavior on implicitWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: 100 } }


    Row {
        id:               row
        anchors.centerIn: parent
        spacing:          12
            
        ColoredIcon {
            source: Qt.resolvedUrl("../../../assets/icons/media/"
                + (MediaService.isPlaying ? "pause.svg" : "play.svg"))
            color: Theme.colorPrimary

            width:  Theme.iconSize
            height: Theme.iconSize
            anchors.verticalCenter: parent.verticalCenter
        }


        // artist — title
        Text {
            anchors.verticalCenter: parent.verticalCenter

            readonly property string artist: MediaService.trackArtist
            readonly property string title:  MediaService.trackTitle

            text: {
                if (artist && title) return artist + "  —  " + title
                return artist || title
            }

            color:          Theme.colorPrimary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontBase
            font.weight:    Font.DemiBold

            // elide long strings
            width:              Math.min(implicitWidth, Theme.mediaWidgetMaxWidth)
            elide:              Text.ElideRight
            maximumLineCount:   1
        } // text

    } // row


    // single click: toggle play/pause
    // double click: open panel
    MouseArea {
        anchors.fill:    parent
        cursorShape:     Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                if (root.panelOpen) PanelLogic.close()
                else if (MediaService.hasMedia) {
                    PanelLogic.open("media", {
                        owner:       root,
                        content:     mediaContent,
                        width:       Theme.mediaPanelWidth,
                        anchorX:     root.mapToGlobal(0, 0).x,
                        anchorWidth: root.width,
                        screen:      root.screen
                    })
                }
            } else {
                if (!root.panelOpen && MediaService.hasMedia)
                    MediaService.togglePlay()
            }
        }
    }

} // item