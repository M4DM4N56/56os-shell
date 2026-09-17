// bar/modules/clock/ClockPanel.qml

import QtQuick
import Quickshell
import "../../../"
import "../../../ui"

// Column {

    Text {
        text:           Time.longDate
        font.weight:    Font.DemiBold
        font.family:    Theme.fontFamily
        font.pixelSize: Theme.fontBase
        color:          Theme.colorPrimary
    }
// }
