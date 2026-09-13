import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs

// One notification, used both as a popup and as a notification center row.
Rectangle {
    id: root

    required property Notification notification

    signal closeRequested

    readonly property string iconSource: {
        if (root.notification.image !== "")
            return root.notification.image;
        if (root.notification.appIcon !== "")
            return Quickshell.iconPath(root.notification.appIcon, true);
        return "";
    }

    implicitHeight: layout.implicitHeight + 24
    radius: Theme.radius
    color: Theme.withAlpha(Theme.mantle, 0.96)
    border.width: 2
    border.color: root.notification.urgency === NotificationUrgency.Critical ? Theme.red : Theme.withAlpha(Theme.surface0, 0.9)

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: 12
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            IconImage {
                implicitSize: 20
                visible: root.iconSource !== ""
                source: root.iconSource
            }

            Text {
                Layout.fillWidth: true
                text: root.notification.appName !== "" ? root.notification.appName : "Notification"
                color: Theme.mauve
                elide: Text.ElideRight
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
            }

            MouseArea {
                id: closeButton

                implicitWidth: 18
                implicitHeight: 18
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.closeRequested()

                Text {
                    anchors.centerIn: parent
                    text: "\uf00d"
                    color: closeButton.containsMouse ? Theme.red : Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }
            }
        }

        Text {
            Layout.fillWidth: true
            visible: root.notification.summary !== ""
            text: root.notification.summary
            color: Theme.text
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
        }

        Text {
            Layout.fillWidth: true
            visible: root.notification.body !== ""
            text: root.notification.body
            textFormat: Text.StyledText
            color: Theme.subtext0
            wrapMode: Text.Wrap
            maximumLineCount: 8
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            onLinkActivated: link => Commands.openUrl(link)
        }

        RowLayout {
            Layout.fillWidth: true
            visible: root.notification.actions.length > 0
            spacing: 6

            Repeater {
                model: root.notification.actions

                delegate: MouseArea {
                    id: action

                    required property NotificationAction modelData

                    Layout.fillWidth: true
                    implicitHeight: 26
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: action.modelData.invoke()

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.pillRadius
                        color: action.containsMouse ? Theme.withAlpha(Theme.mauve, 0.25) : Theme.withAlpha(Theme.surface0, 0.8)
                        border.width: 1
                        border.color: action.containsMouse ? Theme.mauve : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: action.modelData.text
                            color: Theme.text
                            elide: Text.ElideRight
                            width: parent.width - 16
                            horizontalAlignment: Text.AlignHCenter
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 1
                        }
                    }
                }
            }
        }
    }
}
