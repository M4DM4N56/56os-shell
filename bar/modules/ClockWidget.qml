// ClockWidget.qml
import QtQuick // for text
import "../.." // access to singletons


Text {
    // with Time as a singleton, it can be easily accessed without having to think about imports
    text:           Time.time
    font.pixelSize: Theme.fontBase
    font.family:    Theme.fontFamily
    color:          Theme.colorPrimary
    font.weight:    Font.DemiBold
}