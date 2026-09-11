// PanelLogic.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {

    id: root

    // currently-open panel, defaults to null
    property var activePanel: null
    property bool barVisible: true

    function open(panel) {
        if (activePanel && activePanel !== panel) { activePanel.closePanel() }
        activePanel = panel
    }

    function closeAll() {
        if (activePanel) { activePanel.closePanel() }
        activePanel = null
    }

    // marked true when any monitor's active workspace has a fullscreen window
    readonly property bool barObscured: {
        let monitors = Hyprland.monitors?.values ?? []
        return monitors.some(m => m.activeWorkspace?.hasFullscreen ?? false)
    }


} // singleton