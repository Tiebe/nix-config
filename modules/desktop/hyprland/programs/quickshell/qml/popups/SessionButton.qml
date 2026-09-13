import QtQuick
import Quickshell
import qs

// One tile of the session menu.
MouseArea {
    id: root

    property string icon: ""
    property string label: ""
    property string hint: ""

    signal triggered

    implicitWidth: 150
    implicitHeight: 150
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.triggered()

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: root.containsMouse ? Theme.withAlpha(Theme.mauve, 0.2) : Theme.withAlpha(Theme.surface0, 0.9)
        border.width: 2
        border.color: root.containsMouse ? Theme.mauve : Theme.withAlpha(Theme.surface1, 0.8)

        Column {
            anchors.centerIn: parent
            spacing: 10

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.icon
                color: root.containsMouse ? Theme.mauve : Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: 42
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.label
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 1
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.hint
                color: Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
            }
        }
    }
}
