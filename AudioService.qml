// AudioService.qml

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {

    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, ...root.sinkNodes]
    }

    // filter real hardware sinks only
    readonly property var sinkNodes: {
        if (!Pipewire.nodes?.values) return []
        return Pipewire.nodes.values.filter( n =>
            n.isSink && !n.isStream && n.audio !== null && !(n.name ?? "").toLowerCase().includes("monitor")
        )
    }

    onVolumePctChanged: Osd.triggerSimple("volume/" + volumeIconName, volumePct + "%")
    onMutedChanged:     Osd.triggerSimple("volume/" + volumeIconName, muted ? "Muted" : volumePct + "%")

    readonly property int  volumePct: Math.round((Pipewire.defaultAudioSink?.audio?.volume ?? 0) * 100)
    readonly property bool muted:     Pipewire.defaultAudioSink?.audio?.muted ?? false

    readonly property string volumeIconName: {
        if (muted)           return "muted.svg"
        if (volumePct === 0) return "none.svg"
        if (volumePct < 60)  return "low.svg"
        
        return "high.svg"
    }


    readonly property var deviceOverrides: ({ //aghh not working!
        "ALC887-VD Analog": { icon: "headphones.svg", label: "ATH M40x Headphones" }
    })

    function deviceIcon(node) {
        let desc = node.description ?? ""
        if (deviceOverrides[desc]) return deviceOverrides[desc].icon
        let name = (node.name ?? "").toLowerCase()
        desc = desc.toLowerCase()
        if (name.includes("bluez") || desc.includes("bluetooth"))   return "bluetooth.svg"
        if (desc.includes("headphone") || desc.includes("headset")) return "headphones.svg"
        if (desc.includes("hdmi") || desc.includes("display"))      return "monitor.svg"
        return "speaker.svg"
    }

    function deviceLabel(node) {
        let desc = node.description ?? ""
        if (deviceOverrides[desc]) return deviceOverrides[desc].label // if override exists, go crazy mode
        return node.nickname || desc || node.name || "Unknown Device" // return best title possible
    }

    function toggleMute() {
        if (Pipewire.defaultAudioSink?.audio) Pipewire.defaultAudioSink.audio.muted = !muted
    }

    function setDefaultSink(node) {
        Pipewire.preferredDefaultAudioSink = node
    }


} // singleton