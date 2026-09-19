// bar/modules/media/MediaPanel.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../../../"
import "../../../ui/"
import "../../../utils/"


Column {
    
    width:      parent?.width ?? 0

    RowLayout {
        width:   parent?.width ?? 0
        spacing: 10

    // album art
        Item {
            Layout.preferredWidth:  Theme.albumArtSize
            Layout.preferredHeight: Theme.albumArtSize
            Layout.alignment:       Qt.AlignTop

            Rectangle {
                id:            roundMask
                anchors.fill:  parent
                radius:        Theme.albumArtRadius
                color:         Theme.colorSecondary
                layer.enabled: true
            }

            // image — masked to the rounded shape by MultiEffect
            Image {
                anchors.fill: parent
                source:       MediaService.trackArtUrl
                fillMode:     Image.PreserveAspectCrop
                asynchronous: true
                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled:      true
                    maskSource:       roundMask
                    maskThresholdMin: 0.5
                    maskSpreadAtMin:  1.0
                }
            }
        } // item


    // metadata
        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.topMargin: Theme.panelTopPadding
            spacing:          3

            Text {
                width:          parent.width
                text:           MediaService.trackTitle || "Unknown Title"
                color:          Theme.colorPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontBase
                font.weight:    Font.DemiBold
                elide:          Text.ElideRight
            }

            Text {
                width:          parent.width
                text:           MediaService.trackAlbum
                color:          Qt.alpha(Theme.colorPrimary, 0.7)
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSmall
                elide:          Text.ElideRight
                visible:        MediaService.trackAlbum !== ""
            }

            Text {
                width:          parent.width
                text:           MediaService.trackArtist || "Unknown Artist"
                color:          Theme.colorSecondary
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSmall
                elide:          Text.ElideRight
            }

            MediaSeekBar {}

        } // column

    } // row layout
} // column