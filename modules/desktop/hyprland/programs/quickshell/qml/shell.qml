import Quickshell
import Quickshell.Io
import qs.bar
import qs.popups
import qs.services

ShellRoot {
    // One bar per monitor.
    Variants {
        model: Quickshell.screens

        Bar {}
    }

    NotificationPopups {}

    NotificationCenter {}

    SessionMenu {}

    // qs ipc call session <function>
    IpcHandler {
        target: "session"

        function toggle(): void {
            ShellState.sessionOpen = !ShellState.sessionOpen;
        }

        function open(): void {
            ShellState.sessionOpen = true;
        }

        function close(): void {
            ShellState.sessionOpen = false;
        }
    }

    // qs ipc call notifications <function>
    IpcHandler {
        target: "notifications"

        function toggle(): void {
            ShellState.notificationsOpen = !ShellState.notificationsOpen;
        }

        function close(): void {
            ShellState.notificationsOpen = false;
        }

        function clear(): void {
            Notifs.dismissAll();
        }

        function dnd(): void {
            Notifs.toggleDnd();
        }
    }
}
