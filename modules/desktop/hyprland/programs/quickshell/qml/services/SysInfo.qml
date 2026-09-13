pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// CPU / memory / temperature sampled straight from procfs and sysfs.
Singleton {
    id: root

    readonly property int interval: 5000

    property int cpuUsage: 0
    property int memoryUsage: 0
    property real memoryUsedGib: 0
    property real memoryTotalGib: 0
    property int temperature: 0

    readonly property bool temperatureAvailable: root.thermalPath !== ""

    // Thermal zone types that actually report CPU temperature, best first.
    readonly property var thermalZoneTypes: ["x86_pkg_temp", "k10temp", "cpu-thermal", "acpitz"]
    readonly property int thermalZoneLimit: 12

    property string thermalPath: ""
    property real previousBusy: -1
    property real previousTotal: -1

    Component {
        id: fileReader

        FileView {
            blockLoading: true
            printErrors: false
        }
    }

    function readFile(path: string): string {
        const view = fileReader.createObject(root, {
            path: path
        });
        const contents = view.text();
        view.destroy();
        return contents;
    }

    function findThermalZone(): string {
        for (const wanted of root.thermalZoneTypes) {
            for (let zone = 0; zone < root.thermalZoneLimit; zone++) {
                const dir = `/sys/class/thermal/thermal_zone${zone}`;
                if (root.readFile(`${dir}/type`).trim() === wanted)
                    return `${dir}/temp`;
            }
        }

        return "";
    }

    function refreshCpu(): void {
        // "cpu  user nice system idle iowait irq softirq steal guest guest_nice"
        const fields = root.readFile("/proc/stat").split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
        if (fields.length < 8)
            return;

        const total = fields.reduce((sum, value) => sum + value, 0);
        const busy = total - fields[3] - fields[4];

        if (root.previousTotal >= 0 && total > root.previousTotal) {
            const usage = (busy - root.previousBusy) / (total - root.previousTotal) * 100;
            root.cpuUsage = Math.round(Math.max(0, Math.min(100, usage)));
        }

        root.previousBusy = busy;
        root.previousTotal = total;
    }

    function refreshMemory(): void {
        // procfs reports kibibytes.
        const values = {};
        for (const line of root.readFile("/proc/meminfo").split("\n")) {
            const parts = line.split(":");
            if (parts.length === 2)
                values[parts[0]] = parseInt(parts[1], 10);
        }

        const memTotal = values["MemTotal"];
        const available = values["MemAvailable"];
        if (!memTotal || available === undefined)
            return;

        const used = memTotal - available;
        root.memoryTotalGib = memTotal / 1048576;
        root.memoryUsedGib = used / 1048576;
        root.memoryUsage = Math.round(used / memTotal * 100);
    }

    function refreshTemperature(): void {
        if (root.thermalPath === "")
            return;

        const milliCelsius = parseInt(root.readFile(root.thermalPath).trim(), 10);
        if (!isNaN(milliCelsius))
            root.temperature = Math.round(milliCelsius / 1000);
    }

    function refresh(): void {
        root.refreshCpu();
        root.refreshMemory();
        root.refreshTemperature();
    }

    Component.onCompleted: {
        root.thermalPath = root.findThermalZone();
        root.refresh();
    }

    Timer {
        interval: root.interval
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
