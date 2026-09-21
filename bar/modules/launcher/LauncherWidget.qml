// bar/modules/launcher/LauncherWidget.qml
import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../../"
import "../../../ui/"

Item {
    id: root
    required property var screen

    readonly property bool isOpen: PanelLogic.openId === "launcher"

    Component { id: launcherContent; LauncherPanel {} }

    width:   Theme.launcherPanelWidth
    height:  Theme.barHeight

    opacity: isOpen ? 1.0 : 0.0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

    Connections { // emit launcher open function so the current screen opens the panel
        target: PanelLogic
        function onLauncherOpen() {
            if (Hyprland.focusedMonitor?.name !== root.screen.name) return
            PanelLogic.open("launcher", {
                content:     launcherContent,
                width:       Theme.launcherPanelWidth,
                anchorX:     root.mapToGlobal(0, 0).x,
                anchorWidth: root.width,
                screen:      root.screen
            })
        }
    }

    onIsOpenChanged: {
        if (isOpen) {
            searchInput.clear()
            searchInput.forceActiveFocus()
        } else {
            LauncherService.query         = ""
            LauncherService.selectedIndex = 0
        }
    }

    SearchInput {
        id:               searchInput
        anchors.centerIn: parent
        width:            Theme.launcherPanelWidth - Theme.panelPaddingH * 2
        height:           Theme.barHeight
        paddingH:         Theme.buttonPaddingH
        placeholderText:  "search programs…"
        icon:             Qt.resolvedUrl("../../../assets/icons/launcher/search.svg")

        onTextChanged:      LauncherService.query = text
        onSubmitted:        LauncherService.launch(LauncherService.results[LauncherService.selectedIndex])
        onEscaped:          PanelLogic.close()
        onMoveUp:           LauncherService.selectPrev()
        onMoveDown:         LauncherService.selectNext()
    }

} // item