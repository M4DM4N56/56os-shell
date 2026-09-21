// LauncherService.qml
pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property var allApps: { // fetch all .desktop files and filter with blacklist
        let apps = DesktopEntries.applications?.values ?? []
        return apps.filter(a => !root.blacklist.includes(a.id))
    }

    // why did i install kde :(
    property var blacklist: ["assistant", "avahi-discover", "breezestyleconfig", "bssh", "bvnc", 
        "cmake-gui", "com.raspberrypi.rpi-imager", "com.raspberrypi.rpi-imager-uri-handler", "designer", 
        "eos-update", "firewall-config", "io.github.quodlibet.ExFalso", "io.github.quodlibet.QuodLibet", 
        "jconsole-java25-openjdk", "jshell-java25-openjdk", "mpv", "org.kde.haruna", "org.kde.kcalc", 
        "org.kde.kdeconnect.app", "org.kde.kdeconnect.sms", "org.kde.kdeconnect.nonplasma", 
        "kdesystemsettings", "org.kde.kid3", "org.kde.konsole", "org.kde.ark", "eos-apps-info", "eos-log-tool", 
        "eos-quickstart", "eos-update", "lstopo", "stoken-gui", "stoken-gui-small", "org.kde.partitionmanager", 
        "org.kde.kinfocenter", "linguist", "qv4l2", "qvidcap", "qdbusviewer", "yad-settings", "yad-icon-browser", 
        "xgps", "xgpsspeed", "org.pulseaudio.pavucontrol", "org.gnome.Meld", "org.kde.kmenuedit", 
        "rofi-theme-selector", "rofi", "reflector-simple", "systemsettings", "org.kde.plasma-systemmonitor", 
        "uxterm", "xterm", "welcome"
    ]

    property var pinned:    ["discord", "feishin", "obsidian", "proton.vpn.app.gtk", 
        "org.prismlauncher.PrismLauncher", "steam", "org.nicotine_plus.Nicotine", "motrix"
    ]

    // search state
    property string query:         ""
    property int    selectedIndex: 0


    readonly property var results: {
        let apps = allApps
        let q    = query.toLowerCase().trim()

        if (!q) { // no query yet, return pinned programs
            let pinnedApps = root.pinned
                .map(id => apps.find(a => a.id === id))
                .filter(Boolean) // remove nulls for ids not currently installed

            let rest = apps // if not enough pins to fill list, just go alphabetical
                .filter(a => !root.pinned.includes(a.id))
                .sort((a, b) => (a.name ?? "").localeCompare(b.name ?? ""))

            return [...pinnedApps, ...rest].slice(0, 8)
        }

        // updates every query change, log the scores of every program, then order based on score
        let scored = []
        for (let i = 0; i < apps.length; i++) {
            let a       = apps[i]
            let name    = (a.name        ?? "").toLowerCase()
            let generic = (a.genericName ?? "").toLowerCase()
            let keys    = (a.keywords    ?? []).join(" ").toLowerCase()
            let score   = 0

            if (name === q)           score += 10 // exact name
            if (name.startsWith(q))   score += 4  // name starts with
            if (name.includes(q))     score += 2  // name contains
            if (generic.includes(q))  score += 1  // hidden description matches
            if (keys.includes(q))     score += 1  // keyword matches

            if (score > 0) scored.push({ app: a, score: score })
        }

        scored.sort((a, b) => b.score - a.score)
        return scored.map(s => s.app).slice(0, 8)
    }

    onResultsChanged: selectedIndex = 0

    function selectNext() { selectedIndex = Math.min(selectedIndex + 1, results.length - 1) }
    function selectPrev() { selectedIndex = Math.max(selectedIndex - 1, 0) }

    // emit signal after a launch, connected to panelLogic.close() so it can close the launcher
    signal launched(var entry)

    function launch(entry) {
        if (!entry) return
        entry.execute()
        root.launched(entry) // signal update
    }

} // singleton