import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../.."
import "../../../ui"

Item {
    id: root
    required property var screen

    Component { id: wsContent; WorkspacePanel {} }

    // all reactive — functions read sortedMonitors/allWorkspaces internally
    readonly property int activeWsId: WorkspaceService.activeWsId(screen.name)
    readonly property var wsIdList:   WorkspaceService.wsIdList(screen.name)
    readonly property int wsMax:      WorkspaceService.wsMax(screen.name)
    readonly property int wsBase:     WorkspaceService.wsBase(screen.name)

    implicitWidth:  pillsRow.implicitWidth + Theme.modulePadding * 2
    implicitHeight: Theme.barHeight

    Rectangle { // on hover rectangle
        anchors { fill: parent; topMargin: 3; bottomMargin: 3 }
        radius:  Theme.buttonRadius
        color:   Theme.colorSecondary
        opacity: hoverHandler.hovered ? 0.5 : 0.0
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    }

    Row {
        id:               pillsRow
        anchors.centerIn: parent
        spacing:          Theme.wsPillSpacing

        Repeater {
            model: wsIdList

            Rectangle {
                id: pill
                required property var modelData

                readonly property bool focused:  modelData === root.activeWsId
                readonly property bool occupied: WorkspaceService.isOccupied(modelData)
                readonly property bool empty:    !focused && !occupied

                width:  Theme.wsPillWidth
                height: Theme.wsPillHeight
                radius: height / 2
                color:  focused ? Theme.colorPrimary : Theme.colorSecondary

                Behavior on color { ColorAnimation { duration: 200 } }

                transform: Scale {
                    origin.x: pill.width  / 2
                    origin.y: pill.height / 2
                    xScale:   pill.empty  ? 0.6 : 1.0 // empty workspaces are less wide
                    Behavior on xScale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }

            } // rectangle
        } // repeater
    } // row

    TapHandler {
        cursorShape: Qt.PointingHandCursor
        onTapped: { // cycle workspaces, looping back
            let next = root.activeWsId >= root.wsMax ? root.wsBase : root.activeWsId + 1
            Hyprland.dispatch('hl.dsp.focus({workspace="' + next + '"})')
        }
    }

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: if (hovered) PanelLogic.open("workspace", {
            content:     wsContent,
            width:       Theme.workspacePanelWidth,
            anchorX:     root.mapToGlobal(0, 0).x,
            anchorWidth: root.width,
            screen:      root.screen
        })
    }

} // item