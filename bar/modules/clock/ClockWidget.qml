// bar/modules/clock/ClockWidget.qml
import Quickshell
import QtQuick      // for text
import "../../../"  // access to singletons
import "../../../ui/"


Item {
    id: root
    required property var screen

    property bool showDate: false

    implicitWidth:  clockButton.implicitWidth
    implicitHeight: Theme.barHeight
    Component { id: clockContent; ClockPanel {} }
    
    Button {
        id: clockButton

        anchors.verticalCenter: parent.verticalCenter
        implicitHeight: parent.implicitHeight
        hoverInsetV:    3
        
        label:          showDate ? Time.shortDate : Time.time
        labelWeight:    Font.DemiBold
        onClicked:      root.showDate = !root.showDate
    }


    HoverHandler {
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: if (hovered) PanelLogic.open("clock", {
            owner:       root,
            content:     clockContent,
            width:       Theme.clockPanelWidth,
            anchorX:     root.mapToGlobal(0, 0).x,
            anchorWidth: root.width,
            screen:      root.screen
        })
    }

} // item