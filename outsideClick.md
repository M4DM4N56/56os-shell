# Outside-Click & Escape Key: Design Notes

## The core constraint: Wayland input routing

In Wayland, every pointer event is delivered to **exactly one surface** — the compositor picks it, and nothing else sees it. X11 had `XSendEvent` and pointer grabs that let you intercept-and-forward; Wayland has neither. Our layer-shell surface sits above app windows, and when `mask: fullRegion` is active the compositor routes all clicks to us. The app below receives nothing.

**True "close panel AND forward the click to the app below" is not possible in Wayland.** Any design that claims to do this is either faking it or using an X11-only trick.

---

## Why the current design steals clicks

In `ShellSurface.qml`:
```qml
mask: panelHere ? fullRegion : barRegion
```

When a panel is open (`panelHere = true`), the mask expands to the full surface so `PanelHost`'s `MouseArea` can catch clicks anywhere and call `PanelLogic.close()`. That MouseArea consumes the event — the app never sees it.

---

## Option A: Mask-narrowing + Hyprland focus watch (Recommended)

**Core idea:** shrink the mask so clicks outside the panel fall through naturally, then close the panel reactively by watching Hyprland's `activeWindow` instead of catching the click directly.

### What changes

**`ShellSurface.qml` — three mask regions become four:**
```qml
Region { id: emptyRegion }
Region { id: barRegion;   item: barContent }
Region { id: panelRegion; item: panelItem  }   // NEW: just the panel rect
// fullRegion is deleted
```
The `panelItem` reference needs to be exposed from `PanelHost` (its `panel` Item's geometry mapped to surface coordinates).

**Mask logic:**
```qml
mask: {
    if (!shouldShowBar)  return emptyRegion
    if (panelHere)       return barRegion    // bar + panel handled separately
    return barRegion
}
```
Actually the simplest approach: when `panelHere`, set the mask to cover the bar strip only and let `PanelHost` extend it by adding a second `Region` for the panel item, combined via `RegionCombination`. The outside of both regions gets zero coverage → clicks pass through.

**`PanelHost.qml` — remove the outside-click MouseArea:**
```qml
// DELETE this block:
MouseArea {
    anchors.fill: parent
    enabled:      reveal.progress > 0
    onClicked:    PanelLogic.close()
}
```

**`ShellSurface.qml` — add a Hyprland activeWindow watcher:**
```qml
Connections {
    target: Hyprland
    function onActiveWindowChanged() {
        if (PanelLogic.isOpen && PanelLogic.hostScreen?.name === modelData.name)
            PanelLogic.close()
    }
}
```
When the user clicks a different app, Hyprland changes `activeWindow`, and we close. The click already reached the app by the time we react — no steal.

### Edge cases

- **Clicking the already-focused window**: `activeWindow` doesn't change → panel doesn't close. Mitigated by Escape key (see below) and toggle-to-close (clicking the widget again).
- **Short IPC roundtrip**: Hyprland events arrive via socket; the close is a frame or two late. Visually imperceptible.
- **Clicking inside the panel**: panel region is still masked, clicks stay in our surface — works fine.

### Verdict: moderate work, clean result

Two files to change (`ShellSurface`, `PanelHost`), one new `Connections` block, one mask region deleted. The outside-click behavior changes subtly (already-focused-app clicks don't close), but paired with Escape it covers 95% of real use.

---

## Option B: Hover-based panels

**Core idea:** panels open when the pointer enters the widget, close when the pointer leaves the panel+widget region. No clicks involved, no stealing possible.

### What changes

- `WlrKeyboardFocus` stays `None`.
- Mask stays `barRegion` at all times (even with panel open) — outside clicks always fall through.
- Each widget `MouseArea` gains `hoverEnabled: true` and calls `PanelLogic.open()` in `onEntered`, `PanelLogic.close()` in `onExited` (with a debounce timer).
- `PanelHost` needs a "bridge" hover region so the panel doesn't close while the pointer travels from the widget to the panel body. This requires a transparent hit-test rectangle in the gap between widget and panel top.
- `PanelLogic` gains a `closeTimer` (e.g. 120 ms) that is cancelled if the pointer re-enters before it fires.

### Feasibility

Straightforward in QML: `MouseArea.hoverEnabled`, `containsMouse`, a `Timer`. The tricky part is the bridge: since `BarContent` and `PanelHost` are siblings (not parent-child), the panel's top edge being at `y = barHeight` already connects to the bar visually, so the gap is zero. No bridge needed — the pointer never leaves covered surface between bar and panel.

The real downside is **UX**: hover panels feel different. They can close accidentally when the pointer drifts. They're harder to interact with (scroll inside panel → pointer might exit). They're not typical for a status bar with rich panel content (volume sliders, media controls). Recommended only if the panels are read-only or very simple.

---

## Option C: No outside-click close (simplest, lowest fidelity)

Set the mask to `barRegion + panelRegion` always. Remove the full-surface MouseArea entirely. Panel closes only via:
- Clicking the widget button again (toggle — already works)
- Escape key (see below)
- A dedicated close button inside the panel

This is the most minimal change and fully solves click-stealing. The cost is that clicking elsewhere on the screen does nothing to the panel. Combined with Escape this is acceptable, but feels slightly unpolished without Hyprland focus-watch.

---

## Escape key

The surface uses `WlrKeyboardFocus.None`, so QML `Keys` handlers don't fire. Two clean approaches:

### Escape via Hyprland keybind + IPC (Recommended)

Add to Hyprland config:
```ini
bind = , Escape, exec, qs -c ~/.config/quickshell/56os ipc call bar closePanel
```

Add `closePanel` to the `IpcHandler` in `ShellSurface.qml`:
```qml
function closePanel(): void { PanelLogic.close() }
```

**Pros:** zero keyboard stealing, works regardless of what app has focus, one line in Hyprland config, one line in the IPC handler.  
**Cons:** if you ever move the shell config path, the bind breaks. Escape is a global override while the panel is open, which could swallow Escape keystrokes meant for apps (e.g. closing a dialog). Mitigate with a conditional: only bind while `PanelLogic.isOpen`. This requires a dynamic Hyprland keybind — doable but more complex.

A simpler version: just have the keybind always call `closePanel`, which is a no-op when nothing is open. Escape in apps still works because the IPC call just returns immediately and doesn't suppress the compositor from delivering the key to the focused app too. Actually: this depends on how Hyprland handles `bind` — a `bind` with `exec` triggers on keydown and does NOT suppress the key to focused apps. So double-firing is not an issue.

### Escape via `WlrKeyboardFocus.OnDemand`

Change `ShellSurface.qml`:
```qml
WlrLayershell.keyboardFocus: panelHere ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
```

Add to `PanelHost.qml`:
```qml
Keys.onEscapePressed: PanelLogic.close()
focus: host.active
```

**Pros:** self-contained, no Hyprland config needed.  
**Cons:** `OnDemand` requests keyboard focus from the compositor. While the panel is open, the focused app loses key input (e.g., you can't type in a terminal while the volume panel is up). This is the wrong trade-off for a shell bar panel.

**Recommendation: use the Hyprland keybind approach.**

---

## Recommended implementation plan

1. **`ShellSurface.qml`**: delete `fullRegion` / `surfaceFill`, change mask to never use them, add a `Connections { target: Hyprland }` block that calls `PanelLogic.close()` on `activeWindowChanged` when a panel is open here.

2. **`PanelHost.qml`**: delete the outside-click `MouseArea` entirely. Export the panel item's geometry as a property so `ShellSurface` can use it for a `panelRegion` mask (or let the mask just cover barRegion — clicks on the panel itself still land on `PanelBackground`'s `MouseArea` if you add one, or simply pass through to panel content).

3. **`ShellSurface.qml` IPC handler**: add `function closePanel()` alongside `toggle`/`show`/`hide`.

4. **Hyprland config**: add `bind = , Escape, exec, qs -c ~/.config/quickshell/56os ipc call bar closePanel`.

5. **`architecture.md`**: update the input mask section and the data-flow diagram to reflect the new mask logic and close triggers.

### Files touched

| File | Change |
|------|--------|
| `ui/ShellSurface.qml` | Remove `fullRegion`/`surfaceFill`, add Hyprland `activeWindowChanged` watcher, add `closePanel` IPC fn |
| `ui/PanelHost.qml` | Remove outside-click `MouseArea` |
| `architecture.md` | Update mask logic description and data-flow section |
| Hyprland config (outside repo) | Add Escape keybind |

No new files required. `PanelLogic.qml` and all widget/panel files are untouched.
