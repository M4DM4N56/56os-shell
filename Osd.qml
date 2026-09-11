pragma Singleton
import QtQuick
import Quickshell

Singleton {

    id: root

    property bool   mediaOsdEnabled:  true
    property bool   showing:        false
    property string osdType:        ""


    property string simpleIcon:     ""
    property string simpleValue:    ""

    property string mediaArtist:    ""
    property string mediaTrack:     ""
    property int    mediaTracknum:  0
    property url    mediaArt:       ""



    function triggerSimple(icon, value) {
        if (PanelLogic.activePanel !== null) return // dont show when bar is active
        simpleIcon  = icon
        simpleValue = value
        osdType     = "simple"
        showing     = true
        dismissTimer.restart()
    }

    function triggerMedia(artist, track, trackNum, art) {
        if (PanelLogic.activePanel !== null) return
        mediaArtist     = artist
        mediaTrack      = track
        mediaTracknum   = trackNum
        mediaArt        = art
        osdType         = "media"
        showing         = true
        dismissTimer.restart()
    }

    function dismiss() {
        dismissTimer.stop()
        showing = false
    }

    Timer {
        id:             dismissTimer
        interval:       1500
        onTriggered:    root.showing = false
    }

    Connections {
        target: PanelLogic
        function onActivePanelChanged() {
            if (PanelLogic.activePanel !== null) root.dismiss()
        }
    }

} // singleton