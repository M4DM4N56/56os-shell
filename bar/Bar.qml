// Bar.qml
import QtQuick      // for text
import Quickshell   // for PanelWindow
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Io

import ".."                 // access to singletons
import "./modules"          // access to its own modules
import "./modules/volume"   // access volume
import "./modules/media"    // access media
import "../utils"


Scope {

    IpcHandler { // allows for bar toggling (qs ipc call bar toggle)
        target: "bar"
        function toggle(): void { 
            if (PanelLogic.barVisible) PanelLogic.closeAll()
            PanelLogic.barVisible = !PanelLogic.barVisible 
        }
        function show():   void { PanelLogic.barVisible = true  }
        function hide():   void { PanelLogic.barVisible = false }
    }


    Variants {
        model: Quickshell.screens // quickshell maintains number of screens active

		PanelWindow {
            readonly property var hyprMonitor: {
                let monitors = Hyprland.monitors?.values ?? []
                return Utils.findMonitor(monitors, screen.name)
            }

            visible: PanelLogic.barVisible && !(hyprMonitor?.activeWorkspace?.hasFullscreen ?? false)

			required property var modelData // takes in one of the model numbers
			screen: modelData               // displays on corresponding screen

			anchors { top: true; left: true; right: true }
            margins { top: 0; left: Theme.barMarginSide; right: Theme.barMarginSide }
			
            implicitHeight: Theme.barHeight
			color:          "transparent"
			
            
			Rectangle {
                id:             barRect
                anchors.fill:   parent
                color:          Theme.colorBackground
                topLeftRadius:  0
                topRightRadius: 0

                readonly property bool sameScreen: PanelLogic.activePanel !== null
                    && PanelLogic.activePanel.screen?.name === modelData.name

                // corner flattening — only when panel is genuinely at the bar edge
                readonly property bool panelAtLeft:  sameScreen
                    && PanelLogic.activePanel.side === "left"
                    && (PanelLogic.activePanel.isAtEdge ?? false)

                readonly property bool panelAtRight: sameScreen
                    && PanelLogic.activePanel.side === "right"
                    && (PanelLogic.activePanel.isAtEdge ?? false)


                bottomLeftRadius:  barRect.panelAtLeft  ? 0 : Theme.barRadius
                bottomRightRadius: barRect.panelAtRight ? 0 : Theme.barRadius

                Behavior on bottomLeftRadius  { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                Behavior on bottomRightRadius { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }


                RowLayout { // left
                    anchors.left:           parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin:     Theme.barPadding
                    spacing:                Theme.moduleSpacing
                    Layout.alignment:       Qt.AlignVCenter
                    
                    ClockWidget {}
                    WorkspaceIndicator { screen: modelData }
                }


                RowLayout { // center
                    anchors.centerIn:       parent
                    anchors.verticalCenter: parent.verticalCenter
                    MediaWidget { screen: modelData }
                }


                RowLayout { // right
                    anchors.right:          parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin:    Theme.barPadding
                    spacing:                Theme.moduleSpacing
                    Layout.alignment:       Qt.AlignVCenter

                    VolumeWidget { screen: modelData }
                }

            } // rectangle
        } // panel window
    } // variants
} // scope
