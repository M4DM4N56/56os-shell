// ui/SearchInput.qml
import QtQuick
import ".."

Item {
    id: root

    property color  backgroundColor: "transparent"
    property int    radius:          0
    property int    paddingH:        0

    property color  textColor:        Theme.colorPrimary
    property color  placeholderColor: Qt.alpha(Theme.colorPrimary, 0.3)
    property string placeholderText:  "search…"
    property int    fontPixelSize:    Theme.fontBase
    property int    fontWeight:       Font.DemiBold
    property string fontFamily:       Theme.fontFamily

    property url    icon:             ""
    property int    iconSize:         Theme.iconSize
    property color  iconColor:        Qt.alpha(Theme.colorPrimary, 0.3)

    property alias  text: input.text

    signal submitted()
    signal escaped()
    signal moveUp()
    signal moveDown()

    function forceActiveFocus() { input.forceActiveFocus() }
    function clear()            { input.text = "" }

    implicitWidth:  200
    implicitHeight: Theme.barHeight

    readonly property bool hasIcon:      icon.toString() !== ""
    readonly property int  iconSpacing:  hasIcon ? 4 : 0
    readonly property int  inputWidth:   width - paddingH * 2 - (hasIcon ? iconSize + iconSpacing : 0)

    Rectangle {
        anchors.fill: parent
        color:        root.backgroundColor
        radius:       root.radius
    }

    Row {
        anchors.centerIn: parent
        spacing:          root.iconSpacing

        ColoredIcon {
            visible:                root.hasIcon
            anchors.verticalCenter: parent.verticalCenter
            source:                 root.icon
            color:                  root.iconColor
            size:                   root.iconSize
        }

        TextInput {
            id:                     input
            anchors.verticalCenter: parent.verticalCenter
            width:                  root.inputWidth
            color:                  root.textColor
            font.family:            root.fontFamily
            font.pixelSize:         root.fontPixelSize
            font.weight:            root.fontWeight
            selectionColor:         Qt.alpha(root.textColor, 0.3)

            Text {
                anchors.fill:      parent
                text:              root.placeholderText
                color:             root.placeholderColor
                font:              parent.font
                visible:           parent.text === ""
                verticalAlignment: Text.AlignVCenter
            }

            Keys.onReturnPressed:  root.submitted()
            Keys.onEscapePressed:  root.escaped()
            Keys.onUpPressed:   { root.moveUp();   event.accepted = true }
            Keys.onDownPressed: { root.moveDown(); event.accepted = true }
        }

    } // row
} // item