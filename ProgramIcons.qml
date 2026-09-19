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
        "obsidian":         "notepad.svg",
        "btop":             "stats.svg",
        "filezilla":        "share.svg",
        "protonvpn-app":    "private.svg",
        "nicotine":         "nicotine.svg",
        "picard":           "music-info.svg",
        "lrcget":           "lyrics.svg",
        "java":             "game.svg",
        "dolphin":          "file.svg"
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
}