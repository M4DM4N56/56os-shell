pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    // called once at startup to populate window data
    Component.onCompleted: Qt.callLater(Hyprland.refreshToplevels)

    readonly property var sortedMonitors: {
        let monitors = Hyprland.monitors?.values ?? []
        return [...monitors].sort((a, b) => a.x - b.x)
    }

    readonly property var allWorkspaces: Hyprland.workspaces?.values ?? []
    readonly property var allWindows: {
        let wins = Hyprland.toplevels?.values ?? []
        void wins.length   // registers wins.length as a binding dependency
        return wins
    }

    // per-screen helpers

    function monitorIndex(screenName) {
        return sortedMonitors.findIndex(m => m.name === screenName)
    }

    function wsBase(screenName) {
        let idx = monitorIndex(screenName)
        return idx < 0 ? 1 : idx * Theme.wsPerMonitor + 1
    }

    function wsMax(screenName) {
        return wsBase(screenName) + Theme.wsPerMonitor - 1
    }

    function wsIdList(screenName) {
        let base = wsBase(screenName)
        return Array.from({ length: Theme.wsPerMonitor }, (_, i) => base + i)
    }

    function activeWsId(screenName) {
        let m = sortedMonitors.find(m => m.name === screenName)
        return m?.activeWorkspace?.id ?? -1
    }

    // workspace helpers
    function isOccupied(wsId) {
        let ws = allWorkspaces.find(w => w.id === wsId)
        return (ws?.toplevels?.values?.length ?? 0) > 0
    }

    function windowsOnWs(wsId) {
        return allWindows.filter(w => w.workspace?.id === wsId)
    }


} // singleton