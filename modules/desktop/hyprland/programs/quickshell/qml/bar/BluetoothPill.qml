import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs

// Bluetooth adapter state; hidden when the machine has no adapter.
Pill {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property var connected: [...Bluetooth.devices.values].filter(device => device.connected)

    visible: root.adapter !== null
    icon: root.connected.length > 0 ? "\uf294" : "\uf293"
    label: {
        if (root.adapter === null || !root.adapter.enabled)
            return "Off";
        return root.connected.length > 0 ? `${root.connected.length} connected` : "On";
    }
    accent: {
        if (root.adapter === null || !root.adapter.enabled)
            return Theme.overlay0;
        return root.connected.length > 0 ? Theme.blue : Theme.text;
    }
    clickable: true
    tooltipText: {
        if (root.adapter === null)
            return "";

        const lines = [`${root.adapter.name}  ${root.adapter.enabled ? "on" : "off"}`];
        for (const device of root.connected)
            lines.push(device.batteryAvailable ? `${device.name}  ${Math.round(device.battery * 100)}%` : device.name);
        return lines.join("\n");
    }
    onClicked: Commands.openBluetoothSettings()
}
