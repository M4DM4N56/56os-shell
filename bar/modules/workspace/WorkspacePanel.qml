import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../../"
import "../../../ui"

Column {
    width:   parent?.width ?? 0
    spacing: 0

    readonly property string screenName: PanelLogic.hostScreen?.name ?? ""
    readonly property int    activeWsId: WorkspaceService.activeWsId(screenName)
    readonly property var    wsIdList:   WorkspaceService.wsIdList(screenName)

    Component.onCompleted: Qt.callLater(Hyprland.refreshToplevels)

    Repeater {
        model: wsIdList

        delegate: Item {
            required property var modelData

            readonly property int  wsId:       modelData
            readonly property int  displayNum: ((wsId - 1) % Theme.wsPerMonitor) + 1
            readonly property bool isActive:   wsId === activeWsId
            readonly property var  windows:    WorkspaceService.windowsOnWs(wsId)

            width:  parent.width
            height: Theme.iconSize + Theme.buttonPaddingV * 2

            Rectangle {
                anchors.fill: parent
                radius:       Theme.buttonRadius
                color:        Qt.alpha(Theme.colorSecondary, 0.5)
                opacity:      area.containsMouse ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
            }

            RowLayout {
                anchors.left:           parent.left
                anchors.leftMargin:     Theme.buttonPaddingH
                anchors.right:          parent.right
                anchors.rightMargin:    Theme.buttonPaddingH + Theme.indicatorDot + 6
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                ColoredIcon {
                    source: Qt.resolvedUrl("../../../assets/icons/numbers/" + displayNum + ".svg")
                    color:  isActive ? Theme.colorPrimary : Qt.alpha(Theme.colorPrimary, 0.4)
                    Layout.preferredWidth:  Theme.iconSize
                    Layout.preferredHeight: Theme.iconSize
                    Layout.alignment:       Qt.AlignVCenter
                }

                Row {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing:          4

                    Repeater {
                        model: windows.slice(0, 3)

                        delegate: Item {
                            required property var modelData

                            readonly property string iconFile: ProgramIcons.icon(modelData.lastIpcObject?.class ?? "")
                            readonly property bool   hasIcon:  iconFile !== ""

                            width:   Theme.iconSize
                            height:  Theme.iconSize
                            visible: hasIcon

                            ColoredIcon {
                                source: Qt.resolvedUrl("../../../assets/icons/programs/" + iconFile)
                                color:  isActive ? Theme.colorPrimary : Qt.alpha(Theme.colorPrimary, 0.5)
                            }
                        }
                    }

                    Text { // the +n windows overflow text
                        anchors.verticalCenter: parent.verticalCenter
                        visible:        windows.length > 3
                        text:           "+" + (windows.length - 3)
                        color:          Qt.alpha(Theme.colorPrimary, 0.5)
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSmall
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible:        windows.length === 0
                        text:           "——"
                        color:          Qt.alpha(Theme.colorPrimary, 0.25)
                        font.family:    Theme.fontFamily
                        font.pixelSize: Theme.fontSmall
                    }
                }
            }

            Rectangle {
                anchors.right:          parent.right
                anchors.rightMargin:    Theme.buttonPaddingH
                anchors.verticalCenter: parent.verticalCenter
                width:   Theme.indicatorDot
                height:  Theme.indicatorDot
                radius:  Theme.indicatorDot / 2
                color:   Theme.colorPrimary
                opacity: isActive ? 0.95 : 0.0
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
            }

            MouseArea {
                id:           area
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                hoverEnabled: true
                onClicked:    Hyprland.dispatch('hl.dsp.focus({workspace="' + wsId + '"})')
            }
        }
    }
} // column