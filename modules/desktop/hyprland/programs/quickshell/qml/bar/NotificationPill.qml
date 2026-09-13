import QtQuick
import Quickshell
import qs
import qs.services

// Notification indicator: left click toggles the center, right click toggles DND.
Pill {
    id: root

    icon: {
        if (Notifs.dnd)
            return "\uf1f6";
        return Notifs.count > 0 ? "\uf0f3" : "\uf0a2";
    }
    label: Notifs.count > 0 ? `${Notifs.count}` : ""
    accent: {
        if (Notifs.dnd)
            return Theme.overlay0;
        return Notifs.count > 0 ? Theme.yellow : Theme.text;
    }
    clickable: true
    tooltipText: {
        const state = Notifs.dnd ? "Do not disturb" : `${Notifs.count} notification${Notifs.count === 1 ? "" : "s"}`;
        return `${state}\nRight click toggles do not disturb`;
    }
    onClicked: event => {
        if (event.button === Qt.RightButton)
            Notifs.toggleDnd();
        else
            ShellState.notificationsOpen = !ShellState.notificationsOpen;
    }
}
