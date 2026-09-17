pragma Singleton

import Quickshell
import QtQuick


Singleton {

// font ---
    readonly property string fontFamily:    feliumRegular.name             // font family used for bar
    readonly property int    fontBase:      14                             // base size of bar text
    readonly property int    fontSmall:     11                             // small size of bar text
    
    // font loading
    readonly property FontLoader feliumLight:       FontLoader { source: "file:///home/luca/.local/share/fonts/TBJFeliumMono/tbj-felium-mono-demo.light.ttf" }
    readonly property FontLoader feliumRegular:     FontLoader { source: "file:///home/luca/.local/share/fonts/TBJFeliumMono/tbj-felium-mono-demo.regular.ttf" }
    readonly property FontLoader feliumMedium:      FontLoader { source: "file:///home/luca/.local/share/fonts/TBJFeliumMono/tbj-felium-mono-demo.medium.ttf" }
    readonly property FontLoader feliumSemiBold:    FontLoader { source: "file:///home/luca/.local/share/fonts/TBJFeliumMono/tbj-felium-mono-demo.semi-bold.ttf" }
    readonly property FontLoader feliumBold:        FontLoader { source: "file:///home/luca/.local/share/fonts/TBJFeliumMono/tbj-felium-mono-demo.bold.ttf" }
    readonly property FontLoader feliumExtraBold:   FontLoader { source: "file:///home/luca/.local/share/fonts/TBJFeliumMono/tbj-felium-mono-demo.extra-bold.ttf" }
// --- font


// geometry ---
    // bar
    readonly property int barHeight:        36      // the height of the bar
    readonly property int barRadius:        10      // the roundness of the bar's corners
    readonly property int moduleSpacing:    8       // gap between modules
    readonly property int modulePadding:    4       // a module's horizontal padding
    readonly property int barPadding:       8       // internal gap between bar edge and modules
    readonly property int barMarginSide:    6       // margin between monitor edge and bar sides
    readonly property int barEdgeSpace:     20      // minimum clearance between panel and bar edge

    // pill
    readonly property int wsPillHeight:     6
    readonly property int wsPillWidth:      36
    readonly property int wsPillSpacing:    4       // spacing between occupied pills

    // button
    readonly property int buttonRadius:     4
    readonly property int buttonPaddingH:   4
    readonly property int buttonPaddingV:   6
    readonly property int indicatorDot:     7

    // widget
    readonly property int mediaWidgetWidth: 600

    // pop up panels
    readonly property int albumArtRadius:   8
    readonly property int albumArtSize:     80

    readonly property int clockPanelWidth:      300     // the entire width of the volume widget
    readonly property int workspacePanelWidth:  180     // the entire width of the volume widget
    readonly property int mediaPanelWidth:      400
    readonly property int volumePanelWidth:     240     // the entire width of the volume widget
    
    readonly property int panelPaddingH:    20      // padding on all sides of pop up panels
    readonly property int panelPaddingV:    10
    readonly property int panelRadius:      10      // corner radius of panel
    readonly property int panelJoinRadius:  12      // concave junction cap radius

    // icons
    readonly property int iconSize:         16
    readonly property int largeIconSize:    18

    // osd
    readonly property int osdMaxWidth:      640
    readonly property int osdMediaHeight:   50       // taller than bar height

// --- geometry

// animation ---
    readonly property int animFast:         200
    readonly property int animMedium:       600
    readonly property int animSlow:         400
// --- animation

// colors ---
    readonly property color colorBackground:    "#C3C2C1"//"#161616"//"#dfe2ef"//"#e2e2e9"    // neutral white for all variants
    readonly property color colorPrimary:       "#2e2e2e"//"#8EBD93"//"#292e4d"//"#454545"    // neutral gray for all
    readonly property color colorSecondary:     "#90B2A1"//"#33503E"//"#abc7ff"//"#C0C4EB"    // scheme-vibrant secondary
// --- colors


// misc ---
    readonly property int wsPerMonitor:     4
// --- misc

}