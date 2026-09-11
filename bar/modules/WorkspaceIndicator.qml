import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../.."
import "../../utils"

Row {
    // passed in from bar.qml - the screen this bar lives on
    required property var screen

    spacing: Theme.wsPillSpacing

    component WorkspacePill: Rectangle {
        id: pill

        // each pill expects an ID | if it has a window in it | if it is focused
        required property int  wsId 
        required property bool occupied
        required property bool focused
        readonly property bool empty: !occupied && !focused

        width:  Theme.wsPillWidth
        height: Theme.wsPillHeight
        radius: height / 2
        color:  focused ? Theme.colorPrimary : Theme.colorSecondary

        Behavior on color { ColorAnimation { duration: 200 } }

        transform: Scale {
            origin.x: pill.width  / 2
            origin.y: pill.height / 2
            xScale:   pill.empty  ? 0.6 : 1.0

            Behavior on xScale {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape:  Qt.PointingHandCursor // make mouse change icon upon hover
            onClicked:    Hyprland.dispatch('hl.dsp.focus({workspace="' + wsId + '"})') // call hyprland to change to corresponding workspace
        }
    }


    // iterates through the live monitor list to find the HyprlandMonitor that corresponds to this bar's screen
    // used to determine which workspace is active and which workspace IDs belong to this monitor
    readonly property var hyprMonitor: Utils.findMonitor(Hyprland.monitors?.values ?? [], screen.name)

    // get id of whichever workspace is visible on this monitor
    readonly property int activeWsId: hyprMonitor?.activeWorkspace?.id ?? -1


    readonly property int monitorIndex: {
        let monitors = [...(Hyprland.monitors?.values ?? [])]
            .sort((a, b) => a.x - b.x)
        for (let i = 0; i < monitors.length; i++) {
            if (monitors[i].name === screen.name) return i
        }
        return 0
    }

    // monitor 0: base 1 --- monitor 1: base 5
    readonly property int wsBase: monitorIndex * Theme.wsPerMonitor + 1

    // fixed stable array: [1,2,3,4] or [5,6,7,8]
    // never changes shape, so the Repeater never shuffles or duplicates
    readonly property var wsIdList: {
        let ids = []
        for (let i = 0; i < Theme.wsPerMonitor; i++) ids.push(wsBase + i)
        return ids
    }

    Repeater {
        model: wsIdList

        WorkspacePill {
            required property var modelData  // the integer workspace ID

            // look up live IPC data for this ID — null if workspace not yet visited
            readonly property var wsData: {
                let ws = Hyprland.workspaces?.values
                if (!ws) return null
                for (let i = 0; i < ws.length; i++) {
                    if (ws[i].id === modelData) return ws[i]
                }
                return null
            }

            wsId:     modelData
            focused:  modelData === activeWsId
            occupied: (wsData?.toplevels?.values?.length ?? 0) > 0
        }
    } // repeater

} // row