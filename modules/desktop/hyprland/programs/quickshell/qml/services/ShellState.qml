pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

// Shared visibility state for the panels that are toggled over IPC.
Singleton {
    property bool notificationsOpen: false
    property bool sessionOpen: false

    // Panels follow the monitor Hyprland considers focused.
    readonly property var focusedScreen: Quickshell.screens.find(screen => screen.name === (Hyprland.focusedMonitor?.name ?? "")) ?? null
}
