pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs

// Hyprland's Lua configuration reports `"id": null` for every workspace, so
// Quickshell's id-keyed tracking collapses every monitor onto the same
// workspace object. Workspace names are reported correctly, so active and
// focused state is read from `hyprctl monitors -j` on every workspace event.
Singleton {
    id: root

    // Active workspace name per monitor name.
    property var activeByMonitor: ({})
    // Name of the workspace holding input focus.
    property string focusedName: ""

    readonly property var activeNames: Object.values(root.activeByMonitor)

    // Events that can change which workspace is active on any monitor.
    readonly property var watchedEvents: ["workspace", "workspacev2", "focusedmon", "focusedmonv2", "moveworkspace", "moveworkspacev2", "createworkspace", "createworkspacev2", "destroyworkspace", "destroyworkspacev2"]

    function apply(monitors: var): void {
        const active = {};
        let focused = "";

        for (const monitor of monitors) {
            const workspace = monitor.activeWorkspace?.name ?? "";
            active[monitor.name] = workspace;
            if (monitor.focused)
                focused = workspace;
        }

        root.activeByMonitor = active;
        root.focusedName = focused;
    }

    function refresh(): void {
        if (query.running)
            debounce.restart();
        else
            query.running = true;
    }

    Process {
        id: query

        command: [Commands.hyprctl, "monitors", "-j"]

        stdout: StdioCollector {
            id: collector

            onStreamFinished: {
                if (collector.text !== "")
                    root.apply(JSON.parse(collector.text));
            }
        }
    }

    // Workspace switches arrive as bursts of events; one query is enough.
    Timer {
        id: debounce

        interval: 30
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()

    Connections {
        target: Hyprland

        function onRawEvent(event: HyprlandEvent): void {
            if (root.watchedEvents.includes(event.name))
                debounce.restart();
        }
    }
}
