// shell.qml
import Quickshell

import "./bar"
import "./bar/modules"
import "./osd"
import "./ui"
import "./notifications"

Scope {
	ShellSurface {}
	OsdWindow {}
	NotificationPopup {}
}