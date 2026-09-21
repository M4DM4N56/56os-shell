// ui/TabMenu.qml
import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root

    default property list<Item> pages
    property list<string>       tabs:          []
    property list<url>          icons:         []   // optional, parallel to tabs
    property bool               showDividers:  false
    property int                currentIndex:  0

    // style
    property color activeColor:   Theme.colorPrimary
    property color inactiveColor: Theme.colorSecondary
    property int   labelSize:     Theme.fontSmall
    property int   labelWeight:   Font.DemiBold
    property int   iconSize:      Theme.iconSize
    property int   paddingV:      Theme.buttonPaddingV

    implicitWidth:  layout.implicitWidth
    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id:      layout
        anchors  { left: parent.left; right: parent.right; top: parent.top }
        spacing: 6

        // each tab gets an equal share of the full width
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: root.tabs
                delegate: Item {
                    required property string modelData
                    required property int    index

                    Layout.fillWidth: true
                    implicitHeight:   btn.implicitHeight

                    Rectangle {
                        id:      divider
                        visible: root.showDividers && index > 0
                        width:   2
                        height:  parent.height
                        color:   Qt.alpha(Theme.colorSecondary, 0.5)
                    }

                    Button {
                        id:                 btn
                        anchors.left:       parent.left
                        anchors.right:      parent.right
                        anchors.leftMargin: divider.visible ? 1 : 0
                        fillWidth:          true
                        label:              modelData
                        iconSource:         index < root.icons.length ? root.icons[index] : ""
                        iconColor:          root.currentIndex === index ? root.activeColor : root.inactiveColor
                        labelColor:         root.currentIndex === index ? root.activeColor : root.inactiveColor
                        hoverInsetH:        3
                        labelSize:          root.labelSize
                        labelWeight:        root.labelWeight
                        labelAlign:         Text.AlignHCenter
                        iconSize:           root.iconSize
                        paddingV:           root.paddingV
                        paddingH:           0
                        onClicked:          root.currentIndex = index
                    }
                }
            } // repeater

        } // rowlayout

        // height tracks the active pages implicit height
        Item {
            id:               pageContainer
            Layout.fillWidth: true
            implicitHeight:   (root.currentIndex >= 0 && root.currentIndex < root.pages.length)
                ? root.pages[root.currentIndex].implicitHeight : 0
        }

    } // columnlayout

    // adopt pages into the container and wire up visibility + width bindings
    Component.onCompleted: {
        for (let i = 0; i < pages.length; i++) {
            const idx  = i
            const page = pages[i]
            page.parent  = pageContainer
            page.x       = 0
            page.y       = 0
            page.width   = Qt.binding(() => pageContainer.width)
            page.visible = Qt.binding(() => root.currentIndex === idx)
        }
    }

} // item