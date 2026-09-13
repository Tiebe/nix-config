import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs

// StatusNotifierItem tray.
Row {
    id: root

    spacing: 10

    Repeater {
        model: SystemTray.items

        delegate: MouseArea {
            id: item

            required property SystemTrayItem modelData

            implicitWidth: 20
            implicitHeight: Theme.pillHeight
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            onClicked: event => {
                if (event.button === Qt.MiddleButton) {
                    item.modelData.secondaryActivate();
                } else if (event.button === Qt.RightButton || item.modelData.onlyMenu) {
                    if (!item.modelData.hasMenu)
                        return;
                    if (menu.visible)
                        menu.close();
                    else
                        menu.open();
                } else {
                    item.modelData.activate();
                }
            }

            IconImage {
                anchors.centerIn: parent
                implicitSize: 18
                source: item.modelData.icon
            }

            TrayMenu {
                id: menu

                anchorItem: item
                menuHandle: item.modelData.menu
                offsetY: item.height + 6
            }

            Tooltip {
                target: item
                show: item.containsMouse && !menu.visible
                label: item.modelData.tooltipTitle !== "" ? item.modelData.tooltipTitle : item.modelData.title
            }
        }
    }
}
