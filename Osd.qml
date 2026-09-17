// ./osd.qml

pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property bool   mediaOsdEnabled:    true
    property bool   showing:            false
    property url    icon:               ""
    property string text:               ""

    function trigger(iconPath, displayText) {
        if (PanelLogic.isOpen) return // dont show when bar is active
        icon    = iconPath
        text    = displayText
        showing = true
        dismissTimer.restart()
    }

    function dismiss() {
        dismissTimer.stop()
        showing = false
    }

    Timer {
        id:             dismissTimer
        interval:       1500
        onTriggered:    root.showing = false
    }

    Connections {
        target: PanelLogic
        function onOpenIdChanged() {
            if (PanelLogic.isOpen) root.dismiss()
        }
    }

} // singleton