// bar/modules/launcher/LauncherPanel.qml
import QtQuick
import QtQuick.Layouts
import "../../../"
import "../../../ui"

Column {
    width:   parent?.width ?? 0
    spacing: 0

    Connections {
        target: LauncherService
        function onLaunched() { PanelLogic.close() }
    }

    Repeater {
        model: LauncherService.results

        delegate: Button {
            required property var modelData
            required property int index

            readonly property bool selected: index === LauncherService.selectedIndex

            fillWidth:   true
            iconSource:  ProgramIcons.urlOrEmpty(modelData.id) !== ""
                         ? ProgramIcons.urlOrEmpty(modelData.id)
                         : ProgramIcons.url("cube")
            label:       modelData.name
            highlighted: selected

            onClicked: LauncherService.launch(modelData)

            HoverHandler {
                onHoveredChanged: if (hovered) LauncherService.selectedIndex = index
            }
        }
    } // repeater

    Item {
        width:   parent.width
        height:  Theme.barHeight * 0.8
        visible: LauncherService.results.length === 0

        Text {
            anchors.centerIn:  parent
            text:              "no apps found"
            color:             Qt.alpha(Theme.colorPrimary, 0.3)
            font.family:       Theme.fontFamily
            font.pixelSize:    Theme.fontSmall
        }
    }

} // column