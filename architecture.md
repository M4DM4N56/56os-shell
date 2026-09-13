# Shell Architecture

This document describes the current state of the panel and bar system after the unified-surface overhaul (Phases 0–5 done, Phase 6 mostly done). `Panel.qml` is dead but not yet deleted.

---

## File map & ownership tree

```
shell.qml
├── ui/ShellSurface.qml          (one per screen, the single full-screen PanelWindow)
│   ├── ui/BarContent.qml        (bar visuals + all modules; child of the surface)
│   │   ├── bar/modules/ClockWidget.qml
│   │   ├── bar/modules/WorkspaceIndicator.qml
│   │   ├── bar/modules/media/MediaWidget.qml
│   │   │   └── bar/modules/media/MediaPanel.qml  (content Component, not yet instantiated)
│   │   └── bar/modules/volume/VolumeWidget.qml
│   │       └── bar/modules/volume/VolumePanel.qml (content Component, not yet instantiated)
│   │   (bar/modules/TestWidget.qml also lives here)
│   └── ui/PanelHost.qml         (panel item + positioning + reveal; fills the surface)
│       ├── ui/PanelReveal.qml   (progress 0→1 animation engine; QtObject, no visual)
│       └── ui/PanelBackground.qml  (Shape silhouette — body + junction caps)
│           └── [contentLoader: Loader]  (dynamically instantiates whatever PanelLogic.content points to)
└── osd/OsdWindow.qml

Singletons (global, process-wide):
  PanelLogic.qml    — panel open/close controller & shared panel state
  Theme.qml         — design tokens (sizes, colors, animation durations)
  Osd.qml           — OSD controller
  AudioService.qml  — Pipewire volume/mute state
  MediaService.qml  — MPRIS media state
  Time.qml          — wall clock

ui/Panel.qml — DEAD (the old 4-window-per-widget model; unreferenced, still in qmldir — pending deletion)
```

---

## Responsibilities

### `shell.qml`
Entry point. Instantiates `ShellSurface` (which spawns one surface per screen via `Variants`) and `OsdWindow`. Nothing else.

---

### `PanelLogic.qml` — the panel controller (Singleton)
The single source of truth for what panel is open, on which screen, and for which widget instance. It holds the *request*, not the visual — the surface reacts to it.

**Owns:**
- `openId: string` — semantic label for the open panel (`"volume"`, `"media"`, `"test"`, `""` when closed)
- `owner: var` — the specific widget QML object that opened the panel (instance reference)
- `content: Component` — the QML Component blueprint to instantiate inside the panel
- `requestedWidth: int` — how wide the panel should be
- `anchorX: int` — global X of the triggering widget (used by PanelHost for positioning)
- `anchorWidth: int` — width of the triggering widget
- `hostScreen: var` — which screen object should show the panel
- `barVisible: bool` — whether the bar is visible at all (toggled by IPC)
- `isOpen: bool` (readonly) — `openId !== ""`

**API:** `open(id, opts)`, `toggle(id, opts)`, `close()`, `closeAll()`

**Does not own:** any visual, any window. It is pure state.

---

### `ui/ShellSurface.qml`
A `Scope` that uses `Variants` over `Quickshell.screens` to spawn one `PanelWindow` per screen. Each window is full-screen (`top/left/right` anchored, `implicitHeight: screen.height`), transparent, on the `WlrLayer.Top` layer with no keyboard focus.

**Owns:**
- The `IpcHandler` for the `"bar"` target (exposes `toggle`/`show`/`hide` commands)
- One `PanelWindow` per screen (via `Variants`)
- Per-surface: `shouldShowBar` (computed from `PanelLogic.barVisible` and per-screen `hasFullscreen` from the Hypr monitor)
- Per-surface: `exclusiveZone` (= `Theme.barHeight` when bar is visible, 0 when hidden — tells the compositor how much space to reserve)
- Per-surface: the three-state input `mask` (see below)
- `BarContent` (as a child item, top-anchored)
- `PanelHost` (fills the surface)

**Input mask logic (per surface):**
- Bar hidden → `emptyRegion` (no clicks; everything falls through to apps)
- Panel open here → `null` (full surface is clickable; outside-click anywhere closes the panel)
- Bar visible, no panel → `barRegion` (only the bar strip is clickable)

**Does not own:** positioning math, animation, panel visuals — those belong to `PanelHost`.

---

### `ui/BarContent.qml`
A plain `Item` (no window) containing the bar rectangle and all three module `RowLayout`s. It is top-anchored inside the `PanelWindow` surface and has `height: Theme.barHeight`.

**Owns:** the visible bar rectangle and every module widget. Receives `screen` and `modelData` from `ShellSurface` and threads `screen` down to each widget.

**Does not own:** the window/surface, the exclusive zone, the panel.

---

### `ui/PanelHost.qml`
The panel's positioning engine, animation driver, and click-outside catcher. It fills the entire surface (`anchors.fill: parent`) so it can catch clicks anywhere outside the panel.

**Owns:**
- `active: bool` — true when `PanelLogic.isOpen && PanelLogic.hostScreen.name === screen.name` (this surface is the one that should show the panel)
- All positioning math: `widgetSurfaceX`, `side` (left/center/right), `panelLeft` (snaps flush to bar edges near corners), `isAtEdge`
- `PanelReveal` instance (the animation engine)
- The click-outside `MouseArea` (enabled whenever `reveal.progress > 0`; calls `PanelLogic.close()`)
- The single `panel` item (persists across widget switches — this is what enables the morph)
  - `naturalHeight` (content height + padding)
  - `height = reveal.progress * naturalHeight` (the animated reveal)
  - Gated `Behavior`s on `x` and `width` (glide only during open→open swaps, not on fresh opens)
  - `PanelBackground` (the Shape silhouette)
  - An inner clip `Item` containing the `contentLoader`

**Surface coordinate note:** `PanelWindow` origin maps to `screen.x`, not `screen.x + barMarginSide`. Global→surface conversion is therefore `anchorX - screen.x` (no margin term). `barLeft = 0`, `barRight = host.width`.

**Does not own:** the window, the IPC handler, module widgets.

---

### `ui/PanelReveal.qml`
A `QtObject` (no visual) with two properties: `open: bool` and `progress: real` (0→1). When `open` changes, it imperative-sets `progress` to 0 or 1, and a `NumberAnimation` with `Easing.OutExpo` animates the transition over `Theme.animMedium` ms.

Why imperative rather than a binding? So `progress` can be read and gated against (`reveal.progress > 0.99` in the morph behaviors, `> 0.01` in the content keeper) without creating a binding loop.

**Used by:** `PanelHost` (owns it), potentially `OsdWindow` in a future phase.

---

### `ui/PanelBackground.qml`
An `Item` that draws the entire panel silhouette as a single `Shape` with two `ShapePath`s:

1. **`bodyPath()`** — the main panel body: square top (sits over the bar), rounded bottom corners.
2. **`capsPath()`** — concave junction fillets at `y = barHeight` on the non-flush sides (left and/or right). These are drawn *outside* the item's `[0, panelW]` box, which is why nothing in the chain may `clip`.

**Key property:** `effJoin = clamp(0, panelH - barHeight, joinRadius)`. The caps grow from 0 as the panel clears the bar, then lock to `joinRadius`. No cap is drawn until the panel has emerged below the bar.

**Inputs (all from PanelHost):** `panelW`, `panelH` (live animated height), `barHeight`, `capLeft`, `capRight`, `color`.

---

### `ui/Panel.qml` — DEAD
The old architecture: a `Scope` spawning four `PanelWindow`s per widget (catcher, panel body, left cap, right cap). Replaced in full by the `ShellSurface` + `PanelHost` + `PanelBackground` system. Still on disk and still listed in `ui/qmldir`. Pending deletion.

---

### Widget files (`*Widget.qml`)
Each widget follows the same pattern:

1. Defines a local `Component { id: fooContent; FooPanel {} }` — a blueprint, not yet instantiated.
2. Reads `PanelLogic.owner === root` to know if *this instance* currently owns the open panel.
3. On interaction, calls `PanelLogic.toggle(id, { owner: root, content: fooContent, width, anchorX, anchorWidth, screen })`.
4. Passes its own `screen` property (threaded down from `BarContent` → `ShellSurface`) so the right surface hosts the panel.
5. Optionally animates its own width/opacity to "collapse" when it's the open widget.

Widgets do **not** own any panel windows or visual panel infrastructure. They are pure requesters.

---

### Panel content files (`*Panel.qml`)
Plain `Item`/`Column` trees with content only. They read service singletons directly (`AudioService`, `MediaService`). They receive no data through the panel system — the Loader simply instantiates them and they bind to global singletons themselves.

---

### `Osd.qml` (Singleton) + `osd/OsdWindow.qml`
The OSD is an independent subsystem. `Osd.qml` is a singleton controller with `showing`, `osdType`, and payload properties. `OsdWindow.qml` renders it.

The OSD connects to `PanelLogic.onOpenIdChanged`: if the panel opens, the OSD dismisses itself. The OSD's `triggerSimple`/`triggerMedia` functions also guard against being called when `PanelLogic.isOpen` (so a volume keypress while the panel is open doesn't pop the OSD over it).

---

## Data flow: opening a panel end-to-end

```
User clicks VolumeWidget
  → VolumeWidget.MouseArea.onClicked
  → PanelLogic.toggle("volume", { owner: root, content: volumeContent, width: 240,
                                   anchorX: ..., anchorWidth: ..., screen: ... })
  → PanelLogic sets openId, owner, content, requestedWidth, anchorX, anchorWidth, hostScreen

  → ShellSurface.surface.panelHere becomes true (on the matching screen's surface)
      → mask switches to null (whole surface clickable)

  → PanelHost.active becomes true (this surface's screen matches hostScreen)
      → reveal.open = true
      → reveal.progress animates 0 → 1 (OutExpo, animMedium ms)
      → panel.height = reveal.progress * naturalHeight  (panel grows down)
      → PanelBackground.panelH tracks panel.height  (Shape redraws each frame)
      → contentLoader.sourceComponent = PanelLogic.content  (VolumePanel instantiated)
      → contentLoader renders VolumePanel, which reads AudioService directly

User clicks outside
  → PanelHost.MouseArea.onClicked (covers whole surface)
  → PanelLogic.close()  →  openId = "", owner = null
  → PanelHost.active = false  →  reveal.open = false
  → reveal.progress animates 1 → 0  →  panel.height shrinks
  → contentLoader stays loaded until progress < 0.01, then sourceComponent = null
  → ShellSurface mask reverts to barRegion
```

---

## Why does PanelLogic have both `owner` AND `openId`?

**`openId`** is the semantic label — a human-readable string like `"volume"` or `"media"` that names *what kind* of panel is open. It drives `isOpen` (`openId !== ""`), is used by `Osd` to react to panel changes (`onOpenIdChanged`), and is what the IPC handler originally keyed on.

**`owner`** is the instance guard — a reference to the exact QML object that issued the `open()` call.

The problem that necessitated `owner`: if two `VolumeWidget` instances exist (e.g. on two screens, or just hypothetically), they both match `openId === "volume"`. Without `owner`, opening the panel on one screen would make *both* widgets enter the "open" visual state (collapsed, faded). The `toggle()` function would also not know which one to close.

With `owner`, each widget tests `PanelLogic.owner === root` (where `root` is its own instance `id`). Since QML object references are unique per instance, this is always unambiguous. `toggle()` compares `owner === opts.owner` — if the same instance is clicking again, it closes; if a different instance (or a different widget entirely) is clicking, it opens.

**So:** `openId` answers *what* is open (semantic type, used for reactions and IPC). `owner` answers *which one* (instance identity, used for per-widget open state and toggle logic). Both are needed because multiple widgets can share an `openId`.

---

## What does `contentLoader` do and how does it get its information?

`contentLoader` is a QML `Loader` element inside `PanelHost`. A `Loader` dynamically instantiates a QML `Component` at runtime: when its `sourceComponent` property is set to a `Component` object, it creates an instance of that component and renders it in place. When set to `null`, it destroys the instance.

**How it gets its content — the full chain:**

1. A widget defines a local `Component`: `Component { id: volumeContent; VolumePanel {} }`. This is a *blueprint*, not a live object — `VolumePanel` is not instantiated yet.

2. On click, the widget calls `PanelLogic.toggle("volume", { ..., content: volumeContent, ... })`. This passes the `Component` reference (the blueprint object) into `PanelLogic.content`.

3. Inside `PanelHost`, `contentLoader.sourceComponent` is bound to `PanelLogic.content`. When `PanelLogic.content` changes, the `Loader` destroys any previous instance and instantiates the new `Component`.

4. The `Loader` conditionally suppresses this:
   ```qml
   sourceComponent: (host.active || reveal.progress > 0.01)
       ? PanelLogic.content
       : null
   ```
   This keeps the content alive through the close animation (`progress > 0.01` stays true until the panel is nearly gone) so content doesn't vanish mid-fade. Once the panel is fully closed, it sets `null` to free the instance.

5. The instantiated content (e.g. `VolumePanel`) reads whatever data it needs directly from global singletons (`AudioService`, `MediaService`). The panel system passes it *no data* — content components are self-sufficient.

**In short:** the widget owns the blueprint, passes it to `PanelLogic` as a `Component` reference on click, and `PanelHost`'s `Loader` instantiates it. The `Loader` doesn't know or care what the component is — it just holds whatever `PanelLogic.content` points to.
