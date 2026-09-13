import QtQuick
import Quickshell
import qs

// Rounded icon + label bar item.
MouseArea {
    id: root

    property string icon: ""
    property string label: ""
    property color accent: Theme.text
    property color background: Theme.withAlpha(Theme.surface0, 0.55)
    property string tooltipText: ""
    property bool clickable: false

    implicitWidth: content.implicitWidth + 20
    implicitHeight: Theme.pillHeight
    hoverEnabled: true
    cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    Rectangle {
        anchors.fill: parent
        radius: Theme.pillRadius
        color: root.containsMouse && root.clickable ? Theme.withAlpha(Theme.surface1, 0.85) : root.background

        Row {
            id: content

            anchors.centerIn: parent
            spacing: 6

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: root.icon !== ""
                text: root.icon
                color: root.accent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 1
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: root.label !== ""
                text: root.label
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
        }
    }

    Tooltip {
        target: root
        label: root.tooltipText
        show: root.containsMouse
    }
}
