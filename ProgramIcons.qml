// ProgramIcons.qml
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property var iconMap: ({
        "firefox":          "search.svg",
        "kitty":            "terminal.svg",
        "codium":           "code.svg",
        "feishin":          "music.svg",
        "discord":          "discord.svg",
        "vlc":              "vlc.svg",
        "steam":            "game.svg",
        "lrcget":           "lyrics.svg",
        "obsidian":         "notepad.svg",
        "filezilla":        "share.svg",
        "stremio-enhanced": "movie.svg",
        "motrix":           "download.svg",
        "btop":             "stats.svg",

        "org.kde.plasma.emojier":           "emoji.svg",
        "org.kde.okular":                   "notepad.svg",
        "org.kde.dolphin":                  "file.svg",
        "proton.vpn.app.gtk":               "private.svg",
        "org.musicbrainz.picard":           "music-info.svg",
        "org.nicotine_plus.nicotine":       "nicotine.svg",
        "org.prismlauncher.prismlauncher":  "game.svg"
    })

    // always returns a url, cube.svg for unknowns
    function url(windowClass) {
        let file = iconMap[(windowClass ?? "").toLowerCase()] ?? "cube.svg"
        return Qt.resolvedUrl("assets/icons/programs/" + file)
    }

    // returns "" for unknowns
    function urlOrEmpty(windowClass) {
        let file = iconMap[(windowClass ?? "").toLowerCase()]
        return file ? Qt.resolvedUrl("assets/icons/programs/" + file) : ""
    }

} // singleton