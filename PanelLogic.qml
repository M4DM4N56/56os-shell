// PanelLogic.qml
pragma Singleton

import QtQuick
import Quickshell

Singleton {

    id: root
    property bool barVisible: true
    
    // currently-open panel, id defaults to null
    property string     openId:         ""      // human-readable label
    property var        owner:          null    // the object instance that opened it
    property Component  content:        null
    property int        requestedWidth: 240
    property int        anchorX:        0
    property int        anchorWidth:    0
    property var        hostScreen:     null

    readonly property bool isOpen: openId !== ""


    function open(id, opts) {
        openId         = id
        owner          = opts.owner   ?? null
        content        = opts.content
        requestedWidth = opts.width   ?? 240
        anchorX        = opts.anchorX
        anchorWidth    = opts.anchorWidth
        hostScreen     = opts.screen

    }

    // if panel is open and is the exact instance, close panel
    function toggle(id, opts) {
        (isOpen && owner === opts.owner) ? close() : open(id, opts)
    }

    function close() { openId = ""; owner = null }
    function closeAll() { close() } // kept to maintain ipc handler, should clean this up later

} // singleton