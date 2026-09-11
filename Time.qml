// Time.qml

pragma Singleton // this line makes a file a singleton
// a singleton is an object with a singular instance that can be accessed anywhere

import Quickshell
import QtQuick



Singleton { // singletons should always have singleton as type
    id: root

    readonly property string time: Qt.formatDateTime(clock.date, "hh:mm:ss")

	SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

}