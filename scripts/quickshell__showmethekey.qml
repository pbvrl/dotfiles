#!/usr/bin/env -S quickshell -p

// Displays a widget that shows current keypresses.

// Requires:
//   showmethekey-cli
//   quickshell

import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    property var pressedKeys: ({})
    property string displayText: "[   ]"
    Process {
        command: ["showmethekey-cli"]
        running: true
        stdout: SplitParser {
            onRead: data => parseKeyEvents(data)
        }
    }
    function formatKeyName(raw) {
        return (raw.startsWith("KEY_") ? raw.substring(4) : raw).toLowerCase()
    }
    function parseKeyEvents(data) {
        for (const line of data.split('\n')) {
            const trimmed = line.trim()
            if (!trimmed) continue
            try {
                const ev = JSON.parse(trimmed)
                if (ev.state_name === "PRESSED") pressedKeys[ev.key_name] = true
                else if (ev.state_name === "RELEASED") delete pressedKeys[ev.key_name]
                updateDisplayText()
            } catch (e) { /* skip non-JSON lines */ }
        }
    }
    function updateDisplayText() {
        const keys = Object.keys(pressedKeys)
        displayText = keys.length === 0
            ? "[   ]"
            : "[ " + keys.map(formatKeyName).sort().join(" + ") + " ]"
    }
    PanelWindow {
        screen: Quickshell.screens[0]
        anchors { right: true; bottom: true }
        margins { right: 30; bottom: 70 }
        implicitWidth: Math.max(200, label.implicitWidth + 40)
        implicitHeight: label.implicitHeight + 20
        color: "#80000000"
        mask: Region {}
        Text {
            id: label
            anchors.centerIn: parent
            text: displayText
            color: "#ffffff"
            font.pointSize: 14
            font.family: "monospace"
        }
    }
}
