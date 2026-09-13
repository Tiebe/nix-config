import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

// Top bar, one instance per monitor.
PanelWindow {
    id: root

    required property var modelData

    screen: root.modelData
    color: "transparent"
    implicitHeight: Theme.barHeight

    WlrLayershell.namespace: "quickshell-bar"
    WlrLayershell.layer: WlrLayer.Top

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: Theme.barMarginTop
        left: Theme.barMarginSide
        right: Theme.barMarginSide
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: Theme.withAlpha(Theme.base, 0.7)
        border.width: 2
        border.color: Theme.withAlpha(Theme.surface0, 0.6)

        Workspaces {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
        }

        ClockPill {
            anchors.centerIn: parent
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacing

            Pill {
                icon: "\uf4bc"
                label: `${SysInfo.cpuUsage}%`
                accent: Theme.blue
                tooltipText: `CPU ${SysInfo.cpuUsage}%`
            }

            Pill {
                icon: "\ue266"
                label: `${SysInfo.memoryUsage}%`
                accent: Theme.green
                tooltipText: `${SysInfo.memoryUsedGib.toFixed(1)}G / ${SysInfo.memoryTotalGib.toFixed(1)}G`
            }

            Pill {
                visible: SysInfo.temperatureAvailable
                icon: "\uf2c9"
                label: `${SysInfo.temperature}°C`
                accent: SysInfo.temperature >= 80 ? Theme.red : Theme.peach
                tooltipText: `CPU temperature ${SysInfo.temperature}°C`
            }

            BluetoothPill {}

            NetworkPill {}

            BatteryPill {}

            TrayRow {}

            NotificationPill {}
        }
    }
}
