import QtQuick
import QtQuick.Layouts

import ".."
import "../utils/"

Item {
    id:      seekRow
    width:   parent.width
    height:  20
    visible: MediaService.lengthSupported && MediaService.positionSupported

    property bool dragging:     false
    property real dragPosition: 0

    readonly property real displayPosition: dragging
        ? dragPosition
        : (MediaService.activePlayer?.position ?? 0)

    readonly property real progress: MediaService.length > 0
        ? Math.max(0, Math.min(1, displayPosition / MediaService.length))
        : 0

    // current position
    Text {
        id:                     posLabel
        anchors.left:           parent.left
        anchors.verticalCenter: parent.verticalCenter
        text:                   Utils.formatTime(seekRow.displayPosition)
        color:                  Qt.alpha(Theme.colorPrimary, 0.7)
        font.family:            Theme.fontFamily
        font.pixelSize:         Theme.fontSmall
    }

    // duration
    Text {
        id:                     durLabel
        anchors.right:          parent.right
        anchors.verticalCenter: parent.verticalCenter
        text:                   Utils.formatTime(MediaService.length)
        color:                  Qt.alpha(Theme.colorPrimary, 0.7)
        font.family:            Theme.fontFamily
        font.pixelSize:         Theme.fontSmall
    }

    // track between labels
    Item {
        id:                     track
        anchors.left:           posLabel.right
        anchors.right:          durLabel.left
        anchors.leftMargin:     6
        anchors.rightMargin:    6
        anchors.verticalCenter: parent.verticalCenter
        height:                 parent.height

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width:                  parent.width
            height:                 4
            radius:                 1.5
            color:                  Qt.alpha(Theme.colorSecondary, 1)

            Rectangle {
                width:  parent.width * seekRow.progress
                height: parent.height
                radius: parent.radius
                color:  Qt.alpha(Theme.colorPrimary, 0.5)
            }
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            x:      (parent.width - width) * seekRow.progress
            width:  8
            height: 8
            radius: 4
            color:  Theme.colorPrimary
        }

        MouseArea {
            anchors.fill: parent
            cursorShape:  Qt.PointingHandCursor

            function seek(mouseX) {
                let ratio = Math.max(0, Math.min(1, mouseX / width))
                seekRow.dragPosition = ratio * MediaService.length
            }

            onPressed:         (mouse) => { seekRow.dragging = true; seek(mouse.x) }
            onPositionChanged: (mouse) => { if (pressed) seek(mouse.x) }
            onReleased: {
                MediaService.setPosition(seekRow.dragPosition)
                seekRow.dragging = false
            }
        }

    } // item
} // item