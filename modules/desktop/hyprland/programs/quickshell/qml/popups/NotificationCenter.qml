import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs
import qs.bar
import qs.services

// Notification history panel, toggled from the bar or over IPC.
PanelWindow {
    id: root

    visible: ShellState.notificationsOpen
    screen: ShellState.focusedScreen
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: Theme.panelWidth

    WlrLayershell.namespace: "quickshell-notification-center"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: ShellState.notificationsOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors {
        top: true
        right: true
        bottom: true
    }

    margins {
        top: Theme.belowBar
        right: Theme.barMarginSide
        bottom: Theme.barMarginSide
    }

    // Clicking outside the panel closes it.
    HyprlandFocusGrab {
        windows: [root]
        active: ShellState.notificationsOpen
        onCleared: ShellState.notificationsOpen = false
    }

    ScriptModel {
        id: historyModel

        // Newest notification first.
        values: [...Notifs.notifications.values].reverse()
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: Theme.withAlpha(Theme.base, 0.85)
        border.width: 2
        border.color: Theme.withAlpha(Theme.surface0, 0.8)
        focus: true
        Keys.onEscapePressed: ShellState.notificationsOpen = false

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: "Notifications"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize + 2
                    font.bold: true
                }

                Pill {
                    icon: Notifs.dnd ? "\uf1f6" : "\uf0f3"
                    label: Notifs.dnd ? "DND" : "Notify"
                    accent: Notifs.dnd ? Theme.peach : Theme.text
                    clickable: true
                    tooltipText: "Toggle do not disturb"
                    onClicked: Notifs.toggleDnd()
                }

                Pill {
                    icon: "\uf1f8"
                    accent: Theme.red
                    clickable: true
                    tooltipText: "Clear all notifications"
                    onClicked: Notifs.dismissAll()
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: Notifs.count === 0
                text: "No notifications"
                color: Theme.subtext0
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: Notifs.count > 0
                clip: true
                spacing: 8
                model: historyModel

                delegate: NotificationCard {
                    id: card

                    required property Notification modelData

                    width: ListView.view.width
                    notification: card.modelData
                    onCloseRequested: Notifs.dismiss(card.modelData)
                }
            }
        }
    }
}
