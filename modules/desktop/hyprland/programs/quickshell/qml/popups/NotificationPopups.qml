import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs
import qs.services

// Transient notification popups in the top right corner of the focused monitor.
PanelWindow {
    id: root

    visible: Notifs.popups.length > 0
    screen: ShellState.focusedScreen
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: Theme.panelWidth
    implicitHeight: Math.max(1, column.implicitHeight)

    WlrLayershell.namespace: "quickshell-notifications"
    WlrLayershell.layer: WlrLayer.Overlay

    anchors {
        top: true
        right: true
    }

    margins {
        top: Theme.belowBar
        right: Theme.barMarginSide
    }

    // Only the cards themselves take pointer input.
    mask: Region {
        item: column
    }

    ScriptModel {
        id: popupModel

        values: [...Notifs.popups]
    }

    Column {
        id: column

        width: parent.width
        spacing: 8

        Repeater {
            model: popupModel

            delegate: NotificationCard {
                id: card

                required property Notification modelData

                width: column.width
                notification: card.modelData
                onCloseRequested: Notifs.hidePopup(card.modelData)

                // Hovering pauses the timeout so notifications can be read.
                HoverHandler {
                    id: hover
                }

                Timer {
                    interval: Notifs.popupTimeout(card.modelData)
                    running: interval > 0 && !hover.hovered
                    onTriggered: Notifs.hidePopup(card.modelData)
                }
            }
        }
    }
}
