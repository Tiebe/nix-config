import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import qs

// DBusMenu renderer for tray items. Platform menus need Quickshell's
// QApplication mode, so the menu is drawn here instead.
PopupWindow {
    id: root

    required property Item anchorItem
    // QsMenuHandle of the menu (or submenu) to show.
    property var menuHandle: null
    // Offset from the anchor item, used to place submenus beside their parent.
    property int offsetX: 0
    property int offsetY: 0

    signal dismissed

    visible: false
    color: "transparent"
    implicitWidth: 260
    implicitHeight: layout.implicitHeight + 12

    anchor.item: root.anchorItem
    anchor.rect.x: root.offsetX
    anchor.rect.y: root.offsetY

    function open(): void {
        root.visible = true;
    }

    function close(): void {
        submenu.active = false;
        root.visible = false;
        root.dismissed();
    }

    QsMenuOpener {
        id: opener

        menu: root.menuHandle
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.pillRadius
        color: Theme.withAlpha(Theme.mantle, 0.97)
        border.width: 2
        border.color: Theme.withAlpha(Theme.surface0, 0.9)

        Column {
            id: layout

            anchors.fill: parent
            anchors.margins: 6
            spacing: 2

            Repeater {
                model: opener.children

                delegate: MouseArea {
                    id: entry

                    required property QsMenuEntry modelData

                    width: layout.width
                    implicitHeight: entry.modelData.isSeparator ? 7 : 26
                    enabled: entry.modelData.enabled && !entry.modelData.isSeparator
                    hoverEnabled: entry.enabled
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        if (entry.modelData.hasChildren) {
                            submenu.showFor(entry);
                            return;
                        }

                        entry.modelData.triggered();
                        root.close();
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: entry.modelData.isSeparator ? 3 : 0
                        anchors.bottomMargin: entry.modelData.isSeparator ? 3 : 0
                        radius: entry.modelData.isSeparator ? 0 : 6
                        color: {
                            if (entry.modelData.isSeparator)
                                return Theme.withAlpha(Theme.surface0, 0.9);
                            return entry.containsMouse ? Theme.withAlpha(Theme.mauve, 0.25) : "transparent";
                        }

                        Row {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            visible: !entry.modelData.isSeparator
                            spacing: 8

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: entry.modelData.buttonType !== QsMenuButtonType.None
                                text: entry.modelData.checkState === Qt.Checked ? "\uf00c" : "\uf096"
                                color: Theme.mauve
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 2
                            }

                            IconImage {
                                anchors.verticalCenter: parent.verticalCenter
                                implicitSize: 16
                                visible: entry.modelData.icon !== ""
                                source: entry.modelData.icon
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: entry.modelData.text
                                color: entry.modelData.enabled ? Theme.text : Theme.overlay0
                                elide: Text.ElideRight
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 1
                            }
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            visible: entry.modelData.hasChildren
                            text: "\uf054"
                            color: Theme.subtext0
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 3
                        }
                    }
                }
            }
        }
    }

    // Submenus are the same component, anchored beside the parent entry.
    Loader {
        id: submenu

        active: false

        function showFor(entry: Item): void {
            submenu.active = true;
            submenu.item.menuHandle = entry.modelData;
            submenu.item.offsetX = root.offsetX + root.width - 8;
            submenu.item.offsetY = root.offsetY + entry.mapToItem(null, 0, 0).y;
            submenu.item.open();
        }

        source: "TrayMenu.qml"

        onLoaded: {
            submenu.item.anchorItem = root.anchorItem;
            submenu.item.dismissed.connect(() => root.close());
        }
    }

    // Clicking anywhere else dismisses the menu.
    HyprlandFocusGrab {
        windows: [root]
        active: root.visible
        onCleared: root.close()
    }
}
