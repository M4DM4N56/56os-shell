// shell.qml
import Quickshell

import "./bar"
import "./bar/modules"
import "./osd"
import "./ui"

Scope {
	ShellSurface {}
	OsdWindow {}
}