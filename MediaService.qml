pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    // program media priority
    readonly property var priorityList: ["feishin", "vlc", "firefox"]

    function playerPriotity(player) {
        let name = (player.identity ?? "").toLowerCase()
        let entry = (player.desktopEntry ?? "").toLowerCase()
        let idx = priorityList.findIndex(p => name.includes(p) || entry.includes(p))
        return idx === -1 ? 999 : idx // if idk finds nothing, put at back of the priority list. if something found, give it corresponding priority
    }

    readonly property var activePlayer: {
        let players = Mpris.players?.values ?? []
        // ignore players that are stopped or players that do not give track or artist name
        let active = players.filter(p =>
            p.playbackState !== MprisPlaybackState.Stopped && (p.trackTitle !== "" || p.trackArtist !== "")    
        )

        if (active.length === 0) return null
        // find player of highest priority to return
        active.sort((a, b) => playerPriotity(a) - playerPriotity(b))
        return active[0]
    }

    readonly property bool hasMedia:        activePlayer !== null
    readonly property bool isPlaying:       activePlayer?.isPlaying         ?? false
    
    readonly property string trackTitle:    activePlayer?.trackTitle        ?? ""
    readonly property string trackArtist:   activePlayer?.trackArtist       ?? ""
    readonly property string trackAlbum:    activePlayer?.trackAlbum        ?? ""
    readonly property string trackArtUrl:   activePlayer?.trackArtUrl       ?? ""

    readonly property bool canToggle:       activePlayer?.canTogglePlaying  ?? false
    readonly property bool canNext:         activePlayer?.canGoNext         ?? false
    readonly property bool canPrevious:     activePlayer?.canGoPrevious     ?? false

    readonly property real length:            activePlayer?.length            ?? 0
    readonly property bool lengthSupported:   activePlayer?.lengthSupported   ?? false
    readonly property bool positionSupported: activePlayer?.positionSupported ?? false
    readonly property bool canSeek:           activePlayer?.canSeek           ?? false


    function togglePlay() {
        if (activePlayer?.canTogglePlaying) activePlayer.togglePlaying()
    }

    function next() {
        if (activePlayer?.canGoNext) activePlayer.next()
    }

    function previous() {
        if (activePlayer?.canGoPrevious) activePlayer.previous()
    }

    Timer { // 0.5 second timer 
        interval: 500
        running:  MediaService.isPlaying && MediaService.positionSupported
        repeat:   true
        onTriggered: {
            if (MediaService.activePlayer) MediaService.activePlayer.positionChanged()
        }
    }


    function setPosition(seconds) {
        if (activePlayer?.canSeek && activePlayer?.positionSupported)
            activePlayer.position = seconds
    }

    function formatTime(seconds) { // format time from ssss -> mm:ss for displays
        let s = Math.floor(seconds)
        let m = Math.floor(s / 60)
        s = s % 60
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    onTrackTitleChanged: { // call media osd when track updates
        if (!Osd.mediaOsdEnabled || !trackTitle) return
        let display = (trackArtist && trackTitle) ? trackArtist + "  —  " + trackTitle : (trackArtist || trackTitle)
        Osd.trigger("", display)
    }

} // singleton