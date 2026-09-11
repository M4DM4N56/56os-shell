// bar/modules/volume/VolumePanel.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Pipewire
import "../../../"
import "../../../ui"


Column {
    width:   parent?.width ?? 0
    spacing: 0

// mute row ---
    RowLayout {
        width:   parent.width
        height:  Theme.barHeight * 0.8
        spacing: 4

        Item { width: 4 }
        

        // mute toggle
        Item {
            Layout.preferredWidth:  Theme.iconSize
            Layout.preferredHeight: Theme.iconSize
            Layout.alignment:       Qt.AlignVCenter
            width: 80

            ColoredIcon {
                source: Qt.resolvedUrl("../../../assets/icons/volume/"
                              + (AudioService.muted ? "muted.svg" : "low.svg"))
                color: AudioService.muted? Theme.colorSecondary
                    : muteArea.containsMouse? Theme.colorPrimary
                    : Theme.colorPrimary
            }

            MouseArea {
                id: muteArea
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked: { AudioService.toggleMute() }
            }
        } // item

        // label
        Text {
            Layout.fillWidth: true
            text:             AudioService.muted ? "Muted" : "Volume"
            color:            Theme.colorPrimary
            font.family:      Theme.fontFamily
            font.pixelSize:   Theme.fontBase
            font.weight:      Font.DemiBold
        }

        // volume percentage
        Text {
            text:             AudioService.volumePct + "%"
            color:            Qt.alpha(Theme.colorPrimary, 0.5)
            font.family:      Theme.fontFamily
            font.pixelSize:   Theme.fontBase
            font.weight:      Font.DemiBold
        }
    }
// --- mute row


// divider ---
    Rectangle {
        width:  parent.width
        height: 1
        color:  Qt.alpha(Theme.colorSecondary, 0.7)
    }
// --- divider


// device list ---
    Repeater {
        model: AudioService.sinkNodes

        delegate: Item {
            required property var  modelData

            width:  parent.width
            height: Theme.barHeight * 0.8

            readonly property bool isActive: modelData.id === Pipewire.defaultAudioSink?.id

            // subtle hover highlight
            Rectangle {
                anchors.fill: parent
                color:        Theme.colorSecondary
                opacity:      deviceArea.containsMouse ? 0.5 : 0.0
                radius: 5
                Behavior on opacity { NumberAnimation { duration: 100 } }
            }

            RowLayout {
                anchors {
                    fill:           parent
                    leftMargin:     8
                    rightMargin:    8
                    topMargin:      4
                    bottomMargin:   4
                }
                
                spacing: 4

                ColoredIcon {
                    source: Qt.resolvedUrl("../../../assets/icons/devices/"
                                    + AudioService.deviceIcon(modelData))
                    color: isActive ? Theme.colorPrimary : Qt.alpha(Theme.colorPrimary, 0.5)
                    Layout.preferredWidth:  Theme.iconSize
                    Layout.preferredHeight: Theme.iconSize
                }


                // device name
                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    text:             AudioService.deviceLabel(modelData)
                    color:            isActive ? Theme.colorPrimary : Qt.alpha(Theme.colorPrimary, 0.5)
                    font.family:      Theme.fontFamily
                    font.pixelSize:   Theme.fontSmall
                    elide:            Text.ElideRight
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                // active indicator dot
                Rectangle {
                    Layout.preferredWidth:  7
                    Layout.preferredHeight: 7
                    Layout.alignment:       Qt.AlignVCenter
                    radius:                 3.5
                    color:                  Theme.colorPrimary
                    opacity:                isActive ? 0.95 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }
            } // row layout

            MouseArea {
                id:             deviceArea
                anchors.fill:   parent
                cursorShape:    Qt.PointingHandCursor
                hoverEnabled:   true
                onClicked:      AudioService.setDefaultSink(modelData)
            }

        } // item
    } // repeater
// --- device list

} // column