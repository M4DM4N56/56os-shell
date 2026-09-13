# Unified Surface Overhaul — Design Plan

Migrating from today's "one window per bar + 4 windows per panel" model to a
**single full-screen surface per screen** that hosts the bar, the panels, and the
junction caps as one item tree. 

## Goals & principles

- **One surface per screen.** The bar and every panel live in the same window.
- **One animation driver.** A single `progress` value opens/closes; content rides
  it rigidly (no printer effect).
- **Caps are arithmetic, not windows.** The whole silhouette is one `Shape` whose
  path is computed from the live panel height.
- **Panels are centrally hosted, not per-widget.** Widgets *request* a panel from
  a controller; they don't own windows. This is what unlocks the widget→widget
  morph.
- **Keep content files untouched.** `VolumePanel.qml`, `MediaPanel.qml` etc. are
  just `Column`s of content and stay as-is.

---

## Target architecture

### File tree (after)

```
shell.qml                      # unchanged entry point
Theme.qml                      # + real animation durations (see below)
PanelLogic.qml                 # REWORKED: from tracker → controller
ui/
  ShellSurface.qml             # NEW: the one full-screen window per screen
  BarContent.qml               # NEW: bar rect + modules, extracted from Bar.qml
  PanelHost.qml                # NEW: owns the single panel item + positioning + morph
  PanelBackground.qml          # NEW: single Shape silhouette (body + dynamic caps)
  PanelReveal.qml              # NEW: the open/close animation engine
bar/
  Bar.qml                      # DELETED (split into ShellSurface + BarContent)
ui/
  Panel.qml                    # DEAD but still present — pending deletion (still in qmldir)
bar/modules/**/*Widget.qml     # EDITED: call PanelLogic.open/toggle() instead of embedding Panel{}
bar/modules/**/*Panel.qml      # UNCHANGED (content only)
```

### Make / delete summary

| Action | File | Reason |
|--------|------|--------|
| **New** | `ui/ShellSurface.qml` | The per-screen full-screen window; sets layer, exclusive zone, input mask. |
| **New** | `ui/BarContent.qml` | Bar visuals + modules as a plain `Item` (no window). |
| **New** | `ui/PanelHost.qml` | Positioning math + the single panel item + reveal + morph. |
| **New** | `ui/PanelBackground.qml` | One `Shape` for the whole panel outline incl. caps. |
| **New** | `ui/PanelReveal.qml` | `progress` 0→1 animation engine (reusable by OSD). |
| **Rework** | `PanelLogic.qml` | Becomes the open/close controller + geometry + content component. |
| **Deleted** | `bar/Bar.qml` | Its window role → `ShellSurface`; its visuals → `BarContent`. |
| **Pending delete** | `ui/Panel.qml` | The 4-window-per-widget model is gone; file is now dead but not yet removed (still in `qmldir`). |
| **Edited** | `*Widget.qml` | Stop embedding `Panel {}`; call the controller with `owner: root`. |

---

## Data flow: `PanelLogic` as controller

Today `PanelLogic` tracks an `activePanel` *object*. In the new model it holds the
*request* — what to show, where, how big — and the surface reacts to it.

```qml
// PanelLogic.qml  (REWORKED — as built)
pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property bool barVisible: true

    // --- the open request ("" id means nothing is open) ---
    property string    openId:         ""
    property var       owner:          null    // the specific widget INSTANCE that opened it
    property Component content:        null    // component shown in the panel
    property int       requestedWidth: 240
    property int       anchorX:        0       // widget global x
    property int       anchorWidth:    0
    property var       hostScreen:     null    // which screen should host it

    readonly property bool isOpen: openId !== ""

    function open(id, opts) {
        openId         = id
        owner          = opts.owner   ?? null
        content        = opts.content
        requestedWidth = opts.width   ?? 240
        anchorX        = opts.anchorX
        anchorWidth    = opts.anchorWidth
        hostScreen     = opts.screen
    }
    // identity is per-INSTANCE (owner), not per-id — so duplicate widgets that
    // share an id ("volume", ...) don't all react to one being opened.
    function toggle(id, opts) {
        (isOpen && owner === opts.owner) ? close() : open(id, opts)
    }
    function close() { openId = ""; owner = null }   // keep content until fade-out finishes
    function closeAll() { close() }                  // kept for the `bar` IpcHandler
}
```

> **`owner` (added).** The plan originally identified the open panel purely by
> the string `id`. In practice that breaks with duplicate widgets: two
> `VolumeWidget`s both match `openId === "volume"`, so opening one made *both*
> fade out and reserve panel width. The fix is to also record the requesting
> widget instance as `owner`; widgets test `PanelLogic.owner === root`, and
> `toggle` compares owners.

> **`barObscured` moved.** The fullscreen-hide check no longer lives here — it's
> computed per-surface in `ShellSurface` from that screen's Hypr monitor (see
> below), so each screen hides its own bar independently.

Widget call site — no embedded `Panel {}`, no windows, and it passes `owner`:

```qml
// e.g. VolumeWidget.qml  (EDITED)
readonly property bool panelOpen: PanelLogic.owner === root   // this instance

onClicked: PanelLogic.toggle("volume", {
    owner:       root,
    content:     volumeContent,
    width:       Theme.volumePanelWidth,
    anchorX:     root.mapToGlobal(0, 0).x,
    anchorWidth: root.width,
    screen:      root.screen        // passed down from BarContent → ShellSurface's modelData
})

Component { id: volumeContent; VolumePanel {} }
```

---

## Key skeletons

### `ui/ShellSurface.qml` — the one window (per screen)

As built it's a `Scope` that owns the `bar` `IpcHandler` and a `Variants` over
`Quickshell.screens`; each delegate is the full-screen `PanelWindow`. A few
things landed differently from the first sketch:

- **Not bottom-anchored.** Anchoring `top/left/right` (plus side margins) with
  `implicitHeight: screen.height` was enough; no `bottom` anchor / `ExclusionMode`
  needed.
- **`exclusiveZone` toggles with visibility** — `shouldShowBar ? Theme.barHeight : 0`.
- **Fullscreen-hide is local.** Each surface finds its own Hypr monitor
  (`Utils.findMonitor`) and hides its bar on that screen's `hasFullscreen`.
- **Mask uses prebuilt `Region`s**, not an inline one, and has three states.

```qml
Scope {
    IpcHandler {                       // qs ... ipc call bar toggle|show|hide
        target: "bar"
        function toggle(): void { if (PanelLogic.barVisible) PanelLogic.closeAll();
                                  PanelLogic.barVisible = !PanelLogic.barVisible }
        function show(): void   { PanelLogic.barVisible = true  }
        function hide(): void   { PanelLogic.barVisible = false }
    }

    Variants {
        model: Quickshell.screens
        delegate: Component { PanelWindow {
            id: surface
            required property var modelData
            screen: modelData
            color:  "transparent"

            anchors { top: true; left: true; right: true }
            margins { left: Theme.barMarginSide; right: Theme.barMarginSide }
            implicitHeight: screen.height

            WlrLayershell.layer:         WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            readonly property var hyprMonitor:
                Utils.findMonitor(Hyprland.monitors?.values ?? [], screen.name)
            readonly property bool shouldShowBar: PanelLogic.barVisible
                && !(hyprMonitor?.activeWorkspace?.hasFullscreen ?? false)
            exclusiveZone: shouldShowBar ? Theme.barHeight : 0

            readonly property bool panelHere: PanelLogic.isOpen
                && PanelLogic.hostScreen?.name === modelData.name

            // input mask (confirmed working, see Risks):
            //   bar hidden  -> emptyRegion  : nothing clickable, all clicks fall through
            //   panel open  -> null         : whole surface clickable (outside-click closes)
            //   otherwise   -> barRegion    : only the bar strip is clickable
            Region { id: barRegion; item: barContent }
            Region { id: emptyRegion }
            mask: !shouldShowBar ? emptyRegion : (panelHere ? null : barRegion)

            BarContent {
                id: barContent
                screen: modelData; modelData: surface.modelData
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height:  Theme.barHeight
                visible: surface.shouldShowBar
                opacity: surface.shouldShowBar ? 1.0 : 0.0
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
            }

            PanelHost { anchors.fill: parent; screen: modelData }
        } }
    }
}
```

> **Surface coordinate origin.** `PanelHost` fills this surface, and empirically
> `host.mapToGlobal(0,0).x === screen.x` — the `barMarginSide` margin is *not*
> reflected in the mapping. So global→surface conversion is `anchorX - screen.x`
> (no margin subtraction). See the `PanelHost` positioning note.

### `ui/PanelReveal.qml` — the engine

```qml
import QtQuick
import ".."

QtObject {
    property bool open:     false
    property real progress: 0.0

    // imperative (not `progress: open ? 1 : 0`) so `progress` can be *read* and
    // gated against elsewhere without a binding loop — PanelHost checks
    // `progress > 0.99` to decide whether to morph (see below).
    onOpenChanged: progress = open ? 1.0 : 0.0

    Behavior on progress {
        NumberAnimation { duration: Theme.animMedium; easing.type: Easing.OutExpo }
    }
}
```
(Swap for a `SpringAnimation` later per the ideas doc — the rest of the system
doesn't care how `progress` gets to 1.)

### `ui/PanelBackground.qml` — one Shape, dynamic caps

Two changes from the sketch, both driven by where the panel actually sits (it
starts at the *top* of the surface and hangs down through the bar — see
`PanelHost`):

1. **A `barHeight` property.** The concave junction caps aren't at the top of
   the panel; they're at `barHeight`, i.e. where the panel necks out from under
   the bar. `effJoin` therefore grows from the panel's clearance *below the bar*
   (`panelH - barHeight`), not from `panelH`.
2. **Two subpaths, not one.** A `bodyPath()` (square top, rounded bottom
   corners) plus a `capsPath()` (the two fillets). No `Shape` x-offset — earlier
   the single path both offset the `Shape` and drew from negative x, a
   double-shift. The caps draw *outside* the item's box, so nothing in the
   chain may `clip` (see `PanelHost`).

```qml
Item {
    id: root
    property real  panelW:     240
    property real  panelH:     0            // live (animated) height, from panel top
    property real  barHeight:  0            // where the panel necks out of the bar
    property real  radius:     Theme.barRadius
    property real  joinRadius: Theme.panelJoinRadius
    property bool  capLeft:    true
    property bool  capRight:   true
    property color color:      Theme.colorBackground

    // no cap until the panel clears the bar; then it grows 0 → joinRadius.
    readonly property real effJoin: Math.max(0, Math.min(joinRadius, panelH - barHeight))
    clip: false                             // caps live outside [0,panelW]

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath { fillColor: root.color; strokeWidth: -1; PathSvg { path: root.bodyPath() } }
        ShapePath { fillColor: root.color; strokeWidth: -1; PathSvg { path: root.capsPath() } }
    }

    // bodyPath(): M 0 0 → down left → bottom-left arc → across → bottom-right arc → up → Z
    // capsPath(): for each present cap, a small concave fillet at y = barHeight
    //             (left spans x∈[-effJoin,0], right spans x∈[panelW, panelW+effJoin]).
}
```

### `ui/PanelHost.qml` — the meat

Three things settled differently from the sketch while wiring up the volume
panel:

- **Positioning uses `anchorX - screen.x`** (no `barMarginSide` term). The sketch
  assumed the surface origin was inset by the side margin; it isn't (see the
  `ShellSurface` note). Subtracting the margin shifted every widget 6px, which
  inflated the edge gap and defeated the flush-to-edge snap for right-side
  widgets. `barLeft = 0`, `barRight = host.width`.
- **The panel hangs from the top, content flows down.** `panel.y = 0` (surface
  top = bar top); the content `Loader` is anchored to the *top* at
  `panelTopPadding` and flows downward, so it begins at the widget's level (using
  the horizontal space the widget reserves as it expands) rather than appearing
  below the bar and riding up. The first `barHeight` px sit over the bar.
- **Clip lives on an inner container, not on `panel`.** `panel.clip = true` was
  erasing the junction caps (they're drawn outside `[0,width]`). The reveal clip
  now wraps only the content `Loader`; `PanelBackground` is free to draw its caps.

```qml
Item {
    id: host
    required property var screen

    readonly property bool active: PanelLogic.isOpen
        && PanelLogic.hostScreen?.name === screen.name

    // --- positioning (surface coords; origin at screen.x) ---
    readonly property real   barLeft:  0
    readonly property real   barRight: host.width
    readonly property real   widgetSurfaceX: PanelLogic.anchorX - screen.x
    readonly property string side:      { /* center / left / right from anchorX */ }
    readonly property real   panelLeft: { /* snaps flush to barLeft/barRight near an edge */ }
    readonly property bool   isAtEdge:  { /* is the panel flush against a bar edge */ }

    PanelReveal { id: reveal; open: host.active }

    // click-outside-to-close (replaces the old catcher window)
    MouseArea {
        anchors.fill: parent
        enabled: reveal.progress > 0
        onClicked: PanelLogic.close()
    }

    // THE single panel item — persists across widget switches (enables morph)
    Item {
        id: panel
        x:     host.panelLeft
        width: PanelLogic.requestedWidth
        y:     0                                 // top of surface (bar top)
        clip:  false                             // don't clip the caps

        readonly property real naturalHeight:
            contentLoader.implicitHeight + Theme.panelTopPadding + Theme.panelPadding
        height: reveal.progress * naturalHeight

        // Morph glide — GATED. Only animate x/width when a panel is already fully
        // open (a genuine A→B swap, progress pinned at 1). On a fresh open,
        // progress ramps from 0 so these are disabled and the panel snaps into
        // place instead of zipping in from the last panel's position.
        Behavior on x     { enabled: reveal.progress > 0.99; NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
        Behavior on width { enabled: reveal.progress > 0.99; NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

        PanelBackground {
            anchors.fill: parent
            panelW:    panel.width
            panelH:    panel.height
            barHeight: Theme.barHeight
            capLeft:   !(host.side === "left"  && host.isAtEdge)
            capRight:  !(host.side === "right" && host.isAtEdge)
        }

        // content clip region — clips to the revealed height so content flows in
        // from the top (widget level) downward as the panel reveals
        Item {
            anchors.fill: parent
            clip: true
            Loader {
                id: contentLoader
                x:     Theme.panelPadding
                width: panel.width - Theme.panelPadding * 2
                y:     Theme.panelTopPadding      // top-anchored, flows down
                sourceComponent: (host.active || reveal.progress > 0.01)
                    ? PanelLogic.content : null   // stays loaded through the close fade
            }
        }
    }
}
```

Note `contentLoader.sourceComponent` is currently **bound** to `PanelLogic.content`
(there is no crossfade sequence yet — see the morph section below).

### `Theme.qml` — make the animation constants real

They're all `100` and unused today. Give them distinct, meaningful values so the
engine and morph share one vocabulary:

```qml
readonly property int animFast:   150   // morph resize (and content crossfade, when added)
readonly property int animMedium: 250   // panel open/close reveal
readonly property int animSlow:   400
```
(Done — these are the values in `Theme.qml`.)

---

## The widget→widget morph (your fluid-switch idea)

**Yes, and it's the natural behavior of this design.** Because a *single* `panel`
item persists in `PanelHost`, clicking a different widget never closes a window —
it only changes `PanelLogic`'s request (`content`, `requestedWidth`, `anchorX`,
`owner`). The host reacts.

**Current state (as built): the resize/reposition half works, the crossfade
doesn't exist yet.**

1. **`requestedWidth` / `anchorX` change** → `panel.width` / `panel.x` retarget;
   their `Behavior`s glide to the new dimensions — but only while
   `reveal.progress > 0.99`, i.e. during a true open→open swap. `reveal.progress`
   stays at 1 across the swap (a panel was already open), so no re-drop, just a
   glide. On a *fresh* open the gate is closed and the panel snaps.
2. **Content does not crossfade.** `contentLoader.sourceComponent` is a plain
   binding to `PanelLogic.content`, so on a swap the content swaps hard while the
   body glides. The `swap` `SequentialAnimation` (opacity 1→0 → `ScriptAction`
   sets the component → 0→1) from the earlier sketch is **not implemented**.
3. **`naturalHeight` has no `Behavior`.** Height changes track the new content
   immediately (still clipped by the reveal). Add a gated `Behavior` here too if
   the height jump between panels looks abrupt.

To finish the fluid switch: switch `contentLoader.sourceComponent` to imperative
and drive it from a gated `swap` sequence (set it **imperatively**, since a
binding would fight the crossfade). See the "Phase 5" note below.

**Cross-screen switch.** Morph only applies when both widgets are on the same
screen's surface. A request that moves to another screen is a close-here +
open-there, which the `active` flag already handles.

---

## Sequential migration steps

Status: **Phases 0–3 done. Phase 4 done except the `Panel.qml` deletion.
Phase 5 partially done (gated resize; no crossfade). Phase 6 mostly done.**

Do these in order; each phase leaves the shell runnable.

**Phase 0 — De-risk the unknown (throwaway spike).**
Make a scratch full-screen `PanelWindow`: `anchors` all four edges,
`exclusionMode: Normal`, `exclusiveZone: Theme.barHeight`, a small opaque test
rect, and a `mask` that covers only that rect. Confirm: (a) tiled windows reserve
only 36px, (b) clicks outside the rect pass through to apps beneath, (c) toggling
the mask to `null` catches all clicks. **Do not proceed until this holds** — it's
the foundation.

**Phase 1 — Split the bar into surface + content.**
- Create `ui/BarContent.qml`: paste `barRect` + the three `RowLayout`s from
  `Bar.qml:49–105` into a plain `Item`. Drop the `panelAtLeft/panelAtRight`
  corner-flattening for now (the unified caps will own the junction).
- Create `ui/ShellSurface.qml` (skeleton above) hosting `BarContent`, no
  `PanelHost` yet.
- Point `shell.qml`/entry at `ShellSurface` via `Variants`. **Delete `bar/Bar.qml`.**
- Checkpoint: bar renders identically, reserves the right space.

**Phase 2 — Build the animation + drawing primitives.**
- Create `ui/PanelReveal.qml` and `ui/PanelBackground.qml` (skeletons above).
- Fill in the single-`Shape` outline math in `PanelBackground`, including the
  `effJoin` cap clamp. Test it in isolation with a static height slider.

**Phase 3 — Rework the controller + host one widget.**
- Rework `PanelLogic.qml` to the controller API above.
- Create `ui/PanelHost.qml`; move the positioning block from `Panel.qml:15–71`
  into it. Wire `reveal`, `PanelBackground`, and the content `Loader`.
- Migrate **only VolumeWidget** to `PanelLogic.toggle(...)`.
- Checkpoint: volume panel opens/closes with the new rigid slide, caps drawn by
  the single Shape, click-outside closes it. (Printer effect gone.)

**Phase 4 — Migrate remaining widgets, delete old panel.**
- ✅ `MediaWidget` and `TestWidget` converted to `PanelLogic.open/toggle(...)`
  (both pass `owner: root`; open-state is `PanelLogic.owner === root`).
- ⏳ **`ui/Panel.qml` NOT deleted yet.** It's now unreferenced/dead but still on
  disk and still listed in `ui/qmldir`. Deleting it must also remove that qmldir
  line. (Deletion was deferred, not done.)
- Checkpoint: all panels work through the single host. ✅

**Phase 5 — Add the morph.**
- ✅ Gated `Behavior`s on `panel.x`/`panel.width` (`enabled: reveal.progress > 0.99`)
  give the resize/reposition glide on an open→open swap and prevent the fresh-open
  "zip."
- ⏳ **Crossfade not added.** `contentLoader.sourceComponent` is still a plain
  binding; the `swap` `SequentialAnimation` is not implemented. Optionally add a
  gated `Behavior on naturalHeight` too.
- Checkpoint (partial): swapping between right widgets resizes/repositions; content
  currently hard-swaps.

**Phase 6 — Cleanup.**
- ✅ `Theme.anim*` set to real values (150 / 250 / 400).
- ✅ `Osd.qml` reacts to the new controller (`onOpenIdChanged`, was the dead
  `onActivePanelChanged`).
- Old bar corner-flattening properties: gone (dropped in Phase 1).
- ⏳ Consider reusing `PanelReveal` for the OSD's own show/hide.

---

## Risks / things to verify (in priority order)

1. ✅ **Exclusive zone on an all-edges surface.** Resolved. A `top/left/right`
   surface with `implicitHeight: screen.height` and `exclusiveZone: barHeight`
   reserves only the bar height; no `bottom`/`ExclusionMode` needed. The fallback
   two-window plan wasn't necessary.
2. ✅ **Input mask semantics.** Confirmed. `mask: null` = fully interactive,
   a `Region { item: barContent }` = only-bar interactive, and an empty `Region` =
   fully click-through; switching between the three live works.
3. ✅ **Layer choice.** `WlrLayer.Top`. Fullscreen apps hide the bar per-screen
   via each surface's `shouldShowBar` (local `hasFullscreen` check).
4. ⚠️ **`height` double-drive.** Still a latent concern *if* a
   `Behavior on naturalHeight` is added for the morph (it isn't yet). Today
   `height = progress * naturalHeight` and `naturalHeight` has no `Behavior`, so
   there's no contention.
5. ✅ **Reaching the widget's screen.** The screen is threaded down explicitly:
   `ShellSurface` `modelData` → `BarContent.screen` → each widget's
   `screen` property; widgets pass `screen: root.screen` in the `open()` opts. No
   `QsWindow` lookup needed.
6. ✅ **Surface coordinate origin (newly discovered).** `host.mapToGlobal(0,0).x`
   equals `screen.x`, not `screen.x + barMarginSide` — the side margin isn't
   reflected in the mapping. Global→surface is `anchorX - screen.x`. Getting this
   wrong (subtracting the margin) silently shifts panel positioning by
   `barMarginSide` and breaks edge-snapping.
