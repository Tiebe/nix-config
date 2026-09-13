import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

// Power menu overlay, replacing wlogout. Same actions and key hints.
PanelWindow {
    id: root

    visible: ShellState.sessionOpen
    screen: ShellState.focusedScreen
    color: Theme.withAlpha(Theme.base, 0.85)
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "quickshell-session"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: ShellState.sessionOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    function run(command: var): void {
        ShellState.sessionOpen = false;
        Quickshell.execDetached(command);
    }

    Item {
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            switch (event.key) {
            case Qt.Key_Escape:
                ShellState.sessionOpen = false;
                break;
            case Qt.Key_L:
                root.run(Commands.lock);
                break;
            case Qt.Key_E:
                root.run(Commands.logout);
                break;
            case Qt.Key_U:
                root.run(Commands.suspend);
                break;
            case Qt.Key_H:
                root.run(Commands.hibernate);
                break;
            case Qt.Key_S:
                root.run(Commands.shutdown);
                break;
            case Qt.Key_R:
                root.run(Commands.reboot);
                break;
            default:
                return;
            }

            event.accepted = true;
        }

        // Clicking the backdrop closes the menu.
        MouseArea {
            anchors.fill: parent
            onClicked: ShellState.sessionOpen = false
        }

        Row {
            anchors.centerIn: parent
            spacing: 20

            SessionButton {
                icon: "\uf023"
                label: "Lock"
                hint: "L"
                onTriggered: root.run(Commands.lock)
            }

            SessionButton {
                icon: "\uf08b"
                label: "Logout"
                hint: "E"
                onTriggered: root.run(Commands.logout)
            }

            SessionButton {
                icon: "\uf186"
                label: "Suspend"
                hint: "U"
                onTriggered: root.run(Commands.suspend)
            }

            SessionButton {
                icon: "\uf2dc"
                label: "Hibernate"
                hint: "H"
                onTriggered: root.run(Commands.hibernate)
            }

            SessionButton {
                icon: "\uf011"
                label: "Shutdown"
                hint: "S"
                onTriggered: root.run(Commands.shutdown)
            }

            SessionButton {
                icon: "\uf021"
                label: "Reboot"
                hint: "R"
                onTriggered: root.run(Commands.reboot)
            }
        }
    }
}
