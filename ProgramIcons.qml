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
        "LRCGET":           "lyrics.svg",
        "prismlauncher":    "game.svg",
        "java":             "game.svg",
        "dolphin":          "file.svg"
    })

    // returns the icon filename, falling back to cube.svg if unknown
    function icon(windowClass) {
        return iconMap[windowClass.toLowerCase()] ?? "cube.svg"
    }

    // returns a fully resolved URL or "" — safe to pass directly to source:
    function url(windowClass) {
        let file = icon(windowClass)
        return file ? Qt.resolvedUrl("assets/icons/programs/" + file) : ""
    }
}