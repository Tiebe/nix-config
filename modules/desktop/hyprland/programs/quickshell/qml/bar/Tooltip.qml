import QtQuick
import Quickshell
import qs

// Hover tooltip anchored below a bar item.
PopupWindow {
    id: root

    required property Item target
    property string label: ""
    property bool show: false

    visible: root.show && root.label !== ""
    color: "transparent"
    implicitWidth: content.implicitWidth + 20
    implicitHeight: content.implicitHeight + 12

    anchor.item: root.target
    anchor.rect.x: Math.round((root.target.width - root.implicitWidth) / 2)
    anchor.rect.y: root.target.height + 8

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Theme.withAlpha(Theme.mantle, 0.96)
        border.width: 1
        border.color: Theme.withAlpha(Theme.surface0, 0.9)

        Text {
            id: content

            anchors.centerIn: parent
            text: root.label
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
        }
    }
}
