// ui/ColoredIcon.qml

import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import "../"

Item {

    property url    source
    property color  color: Theme.colorPrimary
    property int    size: Theme.iconSize
    width:  size
    height: size
    
    Image {
        id: mask
        anchors.fill: parent
        source: parent.source
        sourceSize: Qt.size(parent.size, parent.size)
        visible: false
    }

    Rectangle {
        anchors.fill: parent
        color: parent.color
        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: mask
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
        }
    }

}

/*
ColoredIcon {
    source: Qt.resolvedUrl("../../../assets/icons/media/play.svg")
    color: Theme.colorPrimary
}
*/