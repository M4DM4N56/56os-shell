// ./notifications/NotificationCard.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."
import "../ui"

Rectangle {
    id: root

    property var    notifId:      null
    property string summary:      ""
    property string body:         ""
    property string appName:      ""
    property string desktopEntry: ""

    property bool compact:  false
    property bool showEye:  true

    signal markRead()
    signal tapped()

    width:          compact ? undefined : Theme.notifToastWidth
    implicitHeight: mainRow.implicitHeight + (compact ? Theme.notifCompactPaddingV : Theme.notifToastPaddingV) * 2
    radius:         Theme.notifRadius
    color:          Theme.colorBackground

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler   { onTapped: root.tapped() }

    Rectangle {
        visible:      root.compact
        anchors.fill: parent
        radius:       root.radius
        color:        Theme.notifHoverColor
        opacity:      hover.hovered ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    }

    RowLayout {
        id: mainRow
        anchors {
            left:           parent.left
            right:          parent.right
            verticalCenter: parent.verticalCenter
            leftMargin:     compact ? Theme.notifCompactPaddingH : Theme.notifToastPaddingH
            // reserve space for the full-height eye button so text never slides under it
            rightMargin:    compact ? Theme.notifCompactPaddingR : (root.showEye ? eyeBtn.width : Theme.notifToastPaddingH)
        }
        spacing: Theme.notifIconSpacing

        ColoredIcon {
            source:                 root.desktopEntry ? ProgramIcons.url(root.desktopEntry) : ""
            visible:                source.toString() !== ""
            size:                   compact ? Theme.iconSize : Theme.largeIconSize
            Layout.preferredWidth:  compact ? Theme.iconSize : Theme.largeIconSize
            Layout.preferredHeight: compact ? Theme.iconSize : Theme.largeIconSize
            Layout.alignment:       Qt.AlignVCenter
        }

        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing:          2

            Text {
                width:          parent.width
                text:           root.summary || root.appName || ""
                color:          Theme.colorPrimary
                font.family:    Theme.fontFamily
                font.pixelSize: compact ? Theme.fontSmall : Theme.fontBase
                font.weight:    Font.DemiBold
                elide:          Text.ElideRight
                visible:        text !== ""
            }

            Text {
                width:            parent.width
                text:             root.body ?? ""
                color:            Theme.notifBodyColor
                font.family:      Theme.fontFamily
                font.pixelSize:   Theme.fontSmall
                elide:            Text.ElideRight
                visible:          text !== ""
                wrapMode:         compact ? Text.NoWrap : Text.WordWrap
                maximumLineCount: compact ? 1 : 2
            }
        } // column

    } // row layout

    Button {
        id:             eyeBtn
        visible:        root.showEye && !root.compact
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        anchors.right:  parent.right
        width:          height

        iconSource:  Qt.resolvedUrl("../assets/icons/notification/eye.svg")
        hoverRadius: Theme.notifRadius
        onClicked:   root.markRead()
    }

} // rectangle