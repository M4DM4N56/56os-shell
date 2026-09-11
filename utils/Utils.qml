// Utils.qml
pragma Singleton
import QtQuick
import Quickshell

Singleton {

    // iterates through the live monitor list to find the HyprlandMonitor that corresponds to this bar's screen
    // used to determine which workspace is active and which workspace IDs belong to this monitor
    function findMonitor(monitors, screenName) {
        if (!monitors) return null
        for (let i = 0; i < monitors.length; i++) {
            if (monitors[i].name === screenName) return monitors[i]
        }
        return null
    }

    function formatTime(seconds) {
        let s = Math.floor(seconds)
        let m = Math.floor(s / 60)
        s = s % 60
        return m + ":" + (s < 10 ? "0" : "") + s
    }

}