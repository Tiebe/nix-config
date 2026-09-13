import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs
import qs.services

// Numbered workspace buttons, ordered like waybar's sort-by-number.
Row {
    id: root

    spacing: Theme.spacing

    ScriptModel {
        id: workspaceModel

        // Workspace ids are unusable with Hyprland's Lua config (see
        // WorkspaceState), so numbered workspaces are keyed by name.
        values: [...Hyprland.workspaces.values].filter(workspace => /^\d+$/.test(workspace.name)).sort((a, b) => Number(a.name) - Number(b.name))
    }

    Repeater {
        model: workspaceModel

        delegate: MouseArea {
            id: button

            required property HyprlandWorkspace modelData

            readonly property bool focused: button.modelData.name === WorkspaceState.focusedName
            readonly property bool active: WorkspaceState.activeNames.includes(button.modelData.name)

            implicitWidth: button.focused ? 34 : 26
            implicitHeight: Theme.pillHeight
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            // Legacy dispatcher names are gone from Hyprland's Lua config.
            onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${button.modelData.name} })`)

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: Theme.pillRadius
                color: {
                    if (button.focused)
                        return Theme.mauve;
                    if (button.active)
                        return Theme.withAlpha(Theme.surface1, 0.9);
                    return button.containsMouse ? Theme.withAlpha(Theme.surface1, 0.6) : Theme.withAlpha(Theme.surface0, 0.55);
                }

                Text {
                    anchors.centerIn: parent
                    // Workspace 10 sits on the SUPER+0 key.
                    text: button.modelData.name === "10" ? "0" : button.modelData.name
                    color: button.focused ? Theme.crust : Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold: button.focused
                }
            }
        }
    }
}
