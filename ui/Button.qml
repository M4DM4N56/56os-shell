// ui/Button.qml

import QtQuick
import QtQuick.Layouts

import ".."

Item {
    id: root

    property url iconSource:    ""
    property string label:      ""

    // color settings
    property color iconColor:   Theme.colorPrimary
    property color labelColor:  Theme.colorPrimary
    property color hoverColor:  Qt.alpha(Theme.colorSecondary, 0.5)

    // icon settings
    property int iconSize:      Theme.iconSize

    // label settings
    property int labelSize:     Theme.fontBase
    property int labelWeight:   Font.DemiBold
    property int labelAlign:    Text.AlignLeft

    // layout
    property int paddingH:      Theme.buttonPaddingH
    property int paddingV:      Theme.buttonPaddingV
    property int hoverInsetV:   0
    property int hoverInsetH:   0
    property int hoverRadius:   Theme.buttonRadius
    property bool fillWidth:    false

    // active indicator dot
    property bool showDot:      false
    property bool isActive:     false
    property bool highlighted:  false

    // expands to parent width or wraps content
    implicitWidth: fillWidth ? parent.width ?? 0 : innerRow.implicitWidth + (paddingH * 2)
    implicitHeight: innerRow.implicitHeight + paddingV * 2

    signal clicked()

    // hover background
    Rectangle {
        anchors {
            fill:         parent
            topMargin:    root.hoverInsetV
            bottomMargin: root.hoverInsetV
            leftMargin:   root.hoverInsetH
            rightMargin:  root.hoverInsetH
        }
        radius:         root.hoverRadius
        color:          hoverColor
        opacity:        area.containsMouse || root.highlighted ? 1 : 0

        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    }

    RowLayout {
        id: innerRow

        anchors.verticalCenter:   parent.verticalCenter
        anchors.horizontalCenter: root.fillWidth ? undefined : parent.horizontalCenter
        anchors.left:             root.fillWidth ? parent.left : undefined
        anchors.leftMargin:       root.fillWidth ? root.paddingH : 0
        anchors.right:            root.fillWidth ? parent.right : undefined
        anchors.rightMargin:      root.fillWidth ? (root.showDot ? root.paddingH + Theme.indicatorDot + 6 : root.paddingH) : 0

        spacing: 4 // spacing between icon and text

        ColoredIcon {
            visible:    root.iconSource.toString() !== ""
            source:     root.iconSource
            color:      root.iconColor
            Layout.preferredWidth:  root.iconSize
            Layout.preferredHeight: root.iconSize
        }

        Text {
            visible:             root.label !== ""
            text:                root.label
            color:               root.labelColor
            font.family:         Theme.fontFamily
            font.pixelSize:      root.labelSize
            font.weight:         root.labelWeight
            elide:               Text.ElideRight
            horizontalAlignment: root.labelAlign
            Layout.fillWidth:    root.fillWidth
            Layout.alignment:    Qt.AlignVCenter
        }

    } // rowlayout

    Rectangle {
        visible:                root.showDot
        anchors.right:          parent.right
        anchors.rightMargin:    root.paddingH
        anchors.verticalCenter: parent.verticalCenter
        width:                  Theme.indicatorDot
        height:                 Theme.indicatorDot
        radius:                 Theme.indicatorDot / 2
        color:                  root.iconColor
        opacity:                root.isActive ? 0.95 : 0.0
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    }

    MouseArea {
        id:           area
        anchors.fill: parent
        cursorShape:  Qt.PointingHandCursor
        hoverEnabled: true
        onClicked:    root.clicked()
    }

} // item