// bar/modules/media/MediaWidget.qml
import QtQuick
import Quickshell
import "../../.."
import "../../../ui/"

Item {
    id: root
    Component { id: mediaContent; MediaPanel {} }

    required property var screen
    readonly property bool panelOpen: PanelLogic.openId === "media"

    readonly property string artist: MediaService.trackArtist
    readonly property string title:  MediaService.trackTitle

    implicitHeight: Theme.barHeight
    implicitWidth:  MediaService.hasMedia 
        ? (panelOpen ? Theme.mediaPanelWidth : contentRow.implicitWidth + Theme.modulePadding * 2)
        : 0
    
    opacity: MediaService.hasMedia ? 1.0 : 0.0

    Behavior on implicitWidth { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
    Behavior on opacity       { NumberAnimation { duration: Theme.animFast } }

    Row { // text row
        id:               contentRow
        anchors.centerIn: parent
        spacing:          8
        opacity:          panelOpen ? 0.0 : 1.0
        visible:          opacity > 0
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: {
                if (artist && title) return artist + "  —  " + title
                return artist || title
            }

            color:          Theme.colorPrimary
            font.family:    Theme.fontFamily
            font.pixelSize: Theme.fontBase
            font.weight:    Font.DemiBold
            width:          Math.min(implicitWidth, Theme.mediaWidgetWidth)
            elide:          Text.ElideRight
            maximumLineCount: 1
        }
    } // row


    Item {
        id:             controlsRow
        anchors.fill:   parent
        opacity:        panelOpen ? 1.0 : 0.0
        visible:        opacity > 0
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

        // prev — left of play
        Button {
            anchors.right:          playBtn.left
            anchors.verticalCenter: parent.verticalCenter
            implicitHeight:         Theme.barHeight
            paddingH:               6
            hoverInsetV:            3
            iconSource:             Qt.resolvedUrl("../../../assets/icons/media/rewind.svg")
            iconColor:              MediaService.canPrevious ? Theme.colorPrimary : Theme.colorSecondary//Qt.alpha(Theme.colorPrimary, 0.3)
            onClicked:              MediaService.previous()
        }

        // play - centered
        Button {
            id:                     playBtn
            anchors.centerIn:       parent
            implicitHeight:         Theme.barHeight
            paddingH:               90
            hoverInsetV:            3
            iconSource:             Qt.resolvedUrl("../../../assets/icons/media/" + (MediaService.isPlaying ? "pause.svg" : "play.svg"))
            onClicked:              MediaService.togglePlay()
        }

        // next — right of play
        Button {
            anchors.left:           playBtn.right
            anchors.verticalCenter: parent.verticalCenter
            implicitHeight:         Theme.barHeight
            paddingH:               6
            hoverInsetV:            3
            iconSource:             Qt.resolvedUrl("../../../assets/icons/media/fast-forward.svg")
            iconColor:              MediaService.canNext ? Theme.colorPrimary : Theme.colorSecondary//Qt.alpha(Theme.colorPrimary, 0.3)
            onClicked:              MediaService.next()
        }

        // info — right
        Button {
            anchors.right:          parent.right
            anchors.rightMargin:    Theme.modulePadding
            anchors.verticalCenter: parent.verticalCenter
            implicitHeight:         Theme.barHeight
            paddingH:               6
            hoverInsetV:            3
            iconSource:             Qt.resolvedUrl("../../../assets/icons/media/info.svg")
            iconColor:              Osd.mediaOsdEnabled ? Theme.colorPrimary : Theme.colorSecondary//Qt.alpha(Theme.colorPrimary, 0.3)
            onClicked:              Osd.mediaOsdEnabled = !Osd.mediaOsdEnabled
        }
    } // item

    // hover: open panel
    HoverHandler {
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: if (hovered && MediaService.hasMedia) PanelLogic.open("media", {
            owner:       root,
            content:     mediaContent,
            width:       Theme.mediaPanelWidth,
            anchorX:     root.mapToGlobal(0, 0).x,
            anchorWidth: root.width,
            screen:      root.screen
        })
    }

} // item