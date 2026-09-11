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

    // album art ---
        Item {
            Layout.preferredWidth:  Theme.albumArtSize
            Layout.preferredHeight: Theme.albumArtSize
            Layout.alignment:       Qt.AlignTop
            Layout.topMargin:       Theme.panelTopPadding

            Rectangle {
                id:            roundMask
                anchors.fill:  parent
                radius:        Theme.albumArtRadius
                color:         "white"
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
        }
    // --- album art


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
                color:          Qt.alpha(Theme.colorPrimary, 0.6)
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSmall
                elide:          Text.ElideRight
                visible:        MediaService.trackAlbum !== ""
            }

            Text {
                width:          parent.width
                text:           MediaService.trackArtist || "Unknown Artist"
                color:          Qt.alpha(Theme.colorPrimary, 0.5)
                font.family:    Theme.fontFamily
                font.pixelSize: Theme.fontSmall
                elide:          Text.ElideRight
            }

        } // column
    // metadata

    } // row layout

    Item { width: 1; height: Theme.panelTopPadding} // vertical padding


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
            color:                  Qt.alpha(Theme.colorPrimary, 0.5)
            font.family:            Theme.fontFamily
            font.pixelSize:         Theme.fontSmall
        }

        // duration
        Text {
            id:                     durLabel
            anchors.right:          parent.right
            anchors.verticalCenter: parent.verticalCenter
            text:                   Utils.formatTime(MediaService.length)
            color:                  Qt.alpha(Theme.colorPrimary, 0.5)
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
                height:                 2
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

    Item { width: 1; height: Theme.panelTopPadding}


    Item {
    width:  parent.width
    height: Theme.iconSize

    // media controls
        Row {
            anchors.centerIn: parent
            spacing:          32

            Item { // rewind button
                width: Theme.iconSize
                height: Theme.iconSize
                visible: MediaService.canPrevious
                anchors.verticalCenter: parent.verticalCenter

                ColoredIcon {
                    source: Qt.resolvedUrl("../../../assets/icons/media/rewind.svg")
                    color: Theme.colorPrimary
                }
                
                MouseArea { 
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: MediaService.previous() 
                }

            } // item

            Item {
                width: 
                Theme.iconSize
                height: Theme.iconSize
                visible: MediaService.canToggle
                anchors.verticalCenter: parent.verticalCenter
                
                ColoredIcon {
                    source: Qt.resolvedUrl("../../../assets/icons/media/"
                        + (MediaService.isPlaying ? "pause.svg" : "play.svg"))
                    color: Theme.colorPrimary
                }
                
                MouseArea { 
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: MediaService.togglePlay() 
                }
            } // item

            Item {
                width: Theme.iconSize
                height: Theme.iconSize
                visible: MediaService.canNext
                anchors.verticalCenter: parent.verticalCenter
                
                ColoredIcon {
                    source: Qt.resolvedUrl("../../../assets/icons/media/fast-forward.svg")
                    color: Theme.colorPrimary
                }

                MouseArea { 
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: MediaService.next() 
                }
            } // item
        // media controls
        } // row

        
        Item { // osd
            width:  Theme.iconSize
            height: Theme.iconSize
            anchors.right:          parent.right
            anchors.verticalCenter: parent.verticalCenter

            ColoredIcon {
                source: Qt.resolvedUrl("../../../assets/icons/media/info.svg")
                color: Osd.mediaOsdEnabled ? Theme.colorPrimary : Theme.colorSecondary
                Behavior on color { ColorAnimation { duration: 100 } }
            }

            MouseArea { 
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Osd.mediaOsdEnabled = !Osd.mediaOsdEnabled 
            }
        } // item

    } // item


} // column