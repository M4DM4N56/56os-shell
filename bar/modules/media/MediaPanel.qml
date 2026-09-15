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
            Layout.topMargin:       Theme.panelTopPadding

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
                color:          Qt.alpha(Theme.colorPrimary, 0.4)
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSmall
                elide:          Text.ElideRight
            }

            MediaSeekBar {}


        } // column

    } // row layout


    //Item { width: 1; height: 10} // vertical padding

    
} // column

    // Item {
    //     width:  parent.width
    //     height: Theme.iconSize

    // // media controls
    //     Row {
    //         anchors.centerIn: parent
    //         spacing:          32

    //         Item { // rewind button
    //             width: Theme.iconSize
    //             height: Theme.iconSize
    //             visible: MediaService.canPrevious
    //             anchors.verticalCenter: parent.verticalCenter

    //             ColoredIcon {
    //                 source: Qt.resolvedUrl("../../../assets/icons/media/rewind.svg")
    //                 color: Theme.colorPrimary
    //             }
                
    //             MouseArea { 
    //                 anchors.fill: parent
    //                 cursorShape: Qt.PointingHandCursor
    //                 onClicked: MediaService.previous() 
    //             }

    //         } // item

    //         Item {
    //             width: 
    //             Theme.iconSize
    //             height: Theme.iconSize
    //             visible: MediaService.canToggle
    //             anchors.verticalCenter: parent.verticalCenter
                
    //             ColoredIcon {
    //                 source: Qt.resolvedUrl("../../../assets/icons/media/"
    //                     + (MediaService.isPlaying ? "pause.svg" : "play.svg"))
    //                 color: Theme.colorPrimary
    //             }
                
    //             MouseArea { 
    //                 anchors.fill: parent
    //                 cursorShape: Qt.PointingHandCursor
    //                 onClicked: MediaService.togglePlay() 
    //             }
    //         } // item

    //         Item {
    //             width: Theme.iconSize
    //             height: Theme.iconSize
    //             visible: MediaService.canNext
    //             anchors.verticalCenter: parent.verticalCenter
                
    //             ColoredIcon {
    //                 source: Qt.resolvedUrl("../../../assets/icons/media/fast-forward.svg")
    //                 color: Theme.colorPrimary
    //             }

    //             MouseArea { 
    //                 anchors.fill: parent
    //                 cursorShape: Qt.PointingHandCursor
    //                 onClicked: MediaService.next() 
    //             }
    //         } // item
    //     // media controls
    //     } // row

        
    //     Item { // osd
    //         width:  Theme.iconSize
    //         height: Theme.iconSize
    //         anchors.right:          parent.right
    //         anchors.verticalCenter: parent.verticalCenter

    //         ColoredIcon {
    //             source: Qt.resolvedUrl("../../../assets/icons/media/info.svg")
    //             color: Osd.mediaOsdEnabled ? Theme.colorPrimary : Theme.colorSecondary
    //             Behavior on color { ColorAnimation { duration: 100 } }
    //         }

    //         MouseArea { 
    //             anchors.fill: parent
    //             cursorShape: Qt.PointingHandCursor
    //             onClicked: Osd.mediaOsdEnabled = !Osd.mediaOsdEnabled 
    //         }
    //     } // item

    // } // item