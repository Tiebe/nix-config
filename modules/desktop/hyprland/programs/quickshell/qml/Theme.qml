pragma Singleton

import QtQuick
import Quickshell

Singleton {
    // Catppuccin Mocha, matching the rest of the Hyprland session.
    readonly property color base: "#1e1e2e"
    readonly property color mantle: "#181825"
    readonly property color crust: "#11111b"
    readonly property color surface0: "#313244"
    readonly property color surface1: "#45475a"
    readonly property color surface2: "#585b70"
    readonly property color overlay0: "#6c7086"
    readonly property color text: "#cdd6f4"
    readonly property color subtext0: "#a6adc8"
    readonly property color mauve: "#cba6f7"
    readonly property color red: "#f38ba8"
    readonly property color peach: "#fab387"
    readonly property color yellow: "#f9e2af"
    readonly property color green: "#a6e3a1"
    readonly property color teal: "#94e2d5"
    readonly property color blue: "#89b4fa"
    readonly property color lavender: "#b4befe"

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13

    readonly property int barHeight: 40
    readonly property int barMarginTop: 6
    readonly property int barMarginSide: 10
    readonly property int radius: 14
    readonly property int pillRadius: 10
    readonly property int pillHeight: 26
    readonly property int spacing: 4
    readonly property int panelWidth: 400

    // Distance from the top of the screen to the bottom edge of the bar.
    readonly property int belowBar: barMarginTop + barHeight + 6

    function withAlpha(source: color, alpha: real): color {
        return Qt.rgba(source.r, source.g, source.b, alpha);
    }
}
