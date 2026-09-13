// ui/PanelReveal.qml
import QtQuick
import ".."


// heavily abstracted, animates from 0 to 1
// used in panel host logic for animations
QtObject {
    id:       root
    property bool open:     false
    property real progress: 0.0

    onOpenChanged: progress = open ? 1.0 : 0.0

    Behavior on progress {
        NumberAnimation {
            duration:    Theme.animMedium
            easing.type: Easing.OutExpo
        }
    }

}