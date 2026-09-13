pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Freedesktop notification daemon plus the popup/center state around it.
Singleton {
    id: root

    // Every notification kept for the notification center, oldest first.
    readonly property alias notifications: server.trackedNotifications
    readonly property int count: server.trackedNotifications.values.length

    // Notifications currently shown as on-screen popups, newest first.
    property var popups: []
    property bool dnd: false

    readonly property int defaultTimeout: 5000
    readonly property int lowTimeout: 3000

    // Critical notifications stay until they are acted on, like swaync did.
    function popupTimeout(notification: Notification): int {
        if (notification.urgency === NotificationUrgency.Critical)
            return 0;
        if (notification.expireTimeout > 0)
            return notification.expireTimeout * 1000;
        return notification.urgency === NotificationUrgency.Low ? root.lowTimeout : root.defaultTimeout;
    }

    // Hide the popup but keep the notification in the center.
    function hidePopup(notification: Notification): void {
        root.popups = root.popups.filter(shown => shown !== notification);
    }

    function dismiss(notification: Notification): void {
        root.hidePopup(notification);
        notification.dismiss();
    }

    function dismissAll(): void {
        root.popups = [];
        for (const notification of [...server.trackedNotifications.values])
            notification.dismiss();
    }

    function toggleDnd(): void {
        root.dnd = !root.dnd;
        if (root.dnd)
            root.popups = [];
    }

    NotificationServer {
        id: server

        keepOnReload: false
        actionsSupported: true
        actionIconsSupported: false
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: false
        imageSupported: true
        persistenceSupported: true

        onNotification: notification => {
            // Tracking keeps the notification alive until it is dismissed here.
            notification.tracked = true;
            notification.closed.connect(() => root.hidePopup(notification));

            if (!root.dnd)
                root.popups = [notification, ...root.popups];
        }
    }
}
