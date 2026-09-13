import QtQuick
import Quickshell
import Quickshell.Networking
import qs

// Active NetworkManager connection; wired wins over wireless.
Pill {
    id: root

    readonly property var devices: [...Networking.devices.values]
    readonly property NetworkDevice wired: root.devices.find(device => device.type === DeviceType.Wired && device.connected) ?? null
    readonly property NetworkDevice wireless: root.devices.find(device => device.type === DeviceType.Wifi && device.connected) ?? null
    readonly property NetworkDevice device: root.wired ?? root.wireless
    readonly property Network network: root.device === null ? null : ([...root.device.networks.values].find(candidate => candidate.connected) ?? null)
    readonly property int signalStrength: root.device === root.wireless && root.network !== null ? Math.round(root.network.signalStrength * 100) : -1

    icon: {
        if (root.device === null)
            return "\uf1e6";
        return root.device === root.wired ? "\uf0e8" : "\uf1eb";
    }
    label: {
        if (root.device === null)
            return "Disconnected";
        return root.network === null ? root.device.name : root.network.name;
    }
    accent: root.device === null ? Theme.red : Theme.blue
    clickable: true
    tooltipText: {
        if (root.device === null)
            return "No network connection";

        const lines = [`${root.device.name}  ${root.network === null ? "connected" : root.network.name}`];
        if (root.signalStrength >= 0)
            lines.push(`Signal ${root.signalStrength}%`);
        if (root.device.address !== "")
            lines.push(root.device.address);
        return lines.join("\n");
    }
    onClicked: Commands.openNetworkSettings()
}
