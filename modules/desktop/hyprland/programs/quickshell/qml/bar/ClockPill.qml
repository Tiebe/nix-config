import QtQuick
import Quickshell
import qs

// Clock; clicking expands it to the full date, like waybar's format-alt.
Pill {
    id: root

    property bool expanded: false

    icon: "\uf017"
    accent: Theme.mauve
    background: Theme.withAlpha(Theme.surface0, 0.7)
    clickable: true
    label: root.expanded ? Qt.formatDateTime(clock.date, "dddd, MMMM d, yyyy  HH:mm") : Qt.formatDateTime(clock.date, "HH:mm")
    tooltipText: Qt.formatDateTime(clock.date, "dddd, MMMM d, yyyy")
    onClicked: root.expanded = !root.expanded

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }
}
