import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs

// Battery state; hidden on machines without a laptop battery.
Pill {
    id: root

    readonly property UPowerDevice battery: UPower.displayDevice
    readonly property bool present: root.battery !== null && root.battery.isLaptopBattery && root.battery.isPresent
    readonly property int percent: root.battery === null ? 0 : Math.round(root.battery.percentage * 100)
    readonly property bool charging: root.battery !== null && (root.battery.state === UPowerDeviceState.Charging || root.battery.state === UPowerDeviceState.FullyCharged)

    // waybar's format-icons, from empty to full.
    readonly property var levelIcons: ["\uf244", "\uf243", "\uf242", "\uf241", "\uf240"]

    function remainingText(): string {
        const seconds = root.charging ? root.battery.timeToFull : root.battery.timeToEmpty;
        if (seconds <= 0)
            return root.charging ? "Charging" : "Discharging";

        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor(seconds % 3600 / 60);
        const time = hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;
        return root.charging ? `${time} until full` : `${time} remaining`;
    }

    visible: root.present
    icon: root.charging ? "\uf0e7" : root.levelIcons[Math.min(root.levelIcons.length - 1, Math.floor(root.percent / 20))]
    label: `${root.percent}%`
    accent: {
        if (root.charging)
            return Theme.green;
        if (root.percent <= 15)
            return Theme.red;
        if (root.percent <= 30)
            return Theme.yellow;
        return Theme.green;
    }
    tooltipText: root.present ? `${root.percent}%  ${root.remainingText()}` : ""
}
