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
    spacing: 2

    Button {
        fillWidth:      true
        labelWeight:    Font.Medium
        iconSource:     Qt.resolvedUrl("../../../assets/icons/volume/" + (AudioService.muted ? "muted.svg" : "low.svg"))
        label:          AudioService.muted ? "Muted" : "Volume"
        iconColor:      AudioService.muted ? Qt.alpha(Theme.colorPrimary, 0.7) : Theme.colorPrimary
        labelColor:     AudioService.muted ? Qt.alpha(Theme.colorPrimary, 0.7) : Theme.colorPrimary
        onClicked:      AudioService.toggleMute()
    }

    // divider
    Rectangle {
        width:  parent.width
        height: 1
        color:  Qt.alpha(Theme.colorSecondary, 1)
    }

    // device list
    Repeater {
        model: AudioService.sinkNodes

        Button {
            required property var modelData
            readonly property bool active: modelData.id === Pipewire.defaultAudioSink?.id

            labelSize:  Theme.fontSmall
            labelWeight: active ? Font.DemiBold : Font.Medium
            fillWidth:  true
            showDot:    true
            isActive:   active
            iconSource: Qt.resolvedUrl("../../../assets/icons/devices/" + AudioService.deviceIcon(modelData))
            label:      AudioService.deviceLabel(modelData)
            iconColor:  active ? Theme.colorPrimary : Qt.alpha(Theme.colorPrimary, 0.7)
            labelColor: active ? Theme.colorPrimary : Qt.alpha(Theme.colorPrimary, 0.7)
            onClicked:  AudioService.setDefaultSink(modelData)
        }
    } // repeater

} // column