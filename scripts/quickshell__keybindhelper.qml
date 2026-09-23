#!/usr/bin/env -S quickshell -p

// Toggles a legend.

// Requires:
//   quickshell

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property var maxWidthFraction: 0.95
    property var maxHeightFraction: 0.95
    property var padding: 20
    property var maxRowsPerColumn: 30
    property var maxRelatedFileRows: 4
    property var title: "Keybind helper"
    property var keybindingGroups: [
        {
            "category": "Keyboard remapper - Kanata",
            "keybindings": [
                { "key": "", "description": "Caps --> Esc" },
                { "key": "", "description": "Right Alt, Kana --> Ctrl" },
                { "key": "", "description": "' --> Enter" },
                { "key": "", "description": "[ --> Backspace" },
                { "key": "", "description": "Super+asdfg --> Super+1-5" },
                { "key": "; (Hold)+hjkl", "description": "Arrow keys" },
                { "key": "; (Hold)+dfc", "description": "Apostrophe, slash, quotes" },
                { "key": "RSuper, Henkan", "description": "Symbols/numbers layer, \nnext keystroke only" },
                { "key": "  ...then a", "description": "Second symbols layer" },
                { "key": "p (Hold)+sedf", "description": "Move mouse" },
                { "key": "p+o (Hold)+sedf", "description": "Move mouse slowly" },
                { "key": "p (Hold)+ag", "description": "Click mouse" },
            ]
        },
        {
            "category": "Compositor - River",
            "keybindings": [
                { "key": "Super+1-9", "description": "Switch to workspace" },
                { "key": "Alt+u", "description": "Toggle claude code (Run 'claude')" },
                { "key": "Alt+i", "description": "Toggle claude code (Run opencode)" },
                { "key": "Alt+h", "description": "Toggle aichat" },
                { "key": "Alt+a", "description": "Dismiss notification (mako)" },
                { "key": "Alt+z", "description": "Toggle notifications" },
                { "key": "Alt+c", "description": "Screenshot to clipboard" },
                { "key": "Alt+d", "description": "Toggle RSS (newsraft)" },
                { "key": "Super+q", "description": "Toggle nmtui (wifi)" },
                { "key": "Super+w", "description": "Toggle pulsemixer (audio)" },
                { "key": "Super+e", "description": "Toggle brightnessctl" },
                { "key": "Super+p", "description": "Fuzzel (App launcher)" },
                { "key": "Super+h", "description": "Toggle this helper" },
                { "key": "Super+Shift+1-9", "description": "Move window to workspace" },
                { "key": "Super+Shift+q", "description": "Close window" },
                { "key": "Super+Shift+e", "description": "Log off" },
            ]
        },
        {
            "category": "Fcitx5",
            "keybindings": [
                { "key": "Super+Shift", "description":  "Switch keyboard language" },
            ]
        },
        {
            "category": "Alacritty",
            "keybindings": [
                { "key": "Alt-f", "description":  "Enter copy mode" },
                { "key": "Enter", "description":  "Exit copy mode, copying selection" },
            ]
        },
        {
            "category": "Handy",
            "keybindings": [
                { "key": "Alt-Space", "description":  "Toggle transcription" },
            ]
        },
        {
            "category": "Tmux",
            "keybindings": [
                { "key": "Alt+t", "description": "New window" },
                { "key": "Alt+w", "description": "Close window/pane" },
                { "key": "Alt+y", "description": "Split panes and open yazi" },
                { "key": "Alt+e", "description": "Toggle focus to nested session" },
                { "key": "Alt+r", "description": "Rename window" },
                { "key": "Alt+n", "description": "Split panes" },
                { "key": "Alt+j", "description": "Focus window/pane to the left" },
                { "key": "Alt+k", "description": "Focus window/pane to the right" },
                { "key": "Alt+g", "description": "Toggle lazygit in session dir" },
                { "key": "Alt+o", "description": "Open sessionizer (sesh)" },
                { "key": "Alt+Tab", "description": "Switch to last sesion" },
                { "key": "Alt+v", "description": "Paste screenshot to claude code" },
                { "key": "Alt+p", "description": "Open command palette" },
                { "key": "Alt+m", "description": "Split panes vertically" },
                { "key": "Alt+Esc", "description": "Tmux extrakto" },
            ]
        },
        {
            "category": "Tmux copy mode",
            "keybindings": [
                { "key": "Alt+f", "description": "Enter copy mode" },
                { "key": "Enter", "description": "Exit copy mode, copying selection" },
                { "key": "jk, Ctrl+ud", "description": "Scroll" },
                { "key": "Shift+v", "description": "Select line" },
                { "key": "o", "description": "Move across selection" },
            ]
        },
        {
            "category": "Helix",
            "keybindings": [
                { "key": "Ctrl+s", "description":  "Write (save changes)" },
            ]
        },
        {
            "category": "Fish",
            "keybindings": [
                { "key": "Ctrl+r", "description":  "History search (atuin)" },
                { "key": "", "description":  "'y' Yazi alias" },
            ]
        },
        {
            "category": "Yazi",
            "keybindings": [
                { "key": "gp", "description": "Go to ~/projects" },
                { "key": "gc", "description": "Go to ~/.config/nixos" },
                { "key": "g...", "description": "Go to ..." },
                { "key": "T", "description": "Toggle preview pane" },
            ]
        },
        {
            "category": "Aichat",
            "keybindings": [
                { "key": "", "description":  "'.session' Starts a session" },
                { "key": "", "description":  "'.exit session' Exits a session" },
                { "key": "", "description":  "'.macro yek DIRNAME PROMPT' \nPrompts model with PROMPT,\nfeeding ~/projects/DIRNAME/ as a file" },
            ]
        },
    ]
    property string sourceFilesRoot: "~/.config/nixos/"
    property var sourceFiles: [
        "~/.config/nixos/dotfiles/kanata/kanata.kbd",
        "~/.config/nixos/scripts_as_dotfiles/quickshell/keyboard_overlay.qml",
        "~/.config/nixos/scripts/river/init",
        "~/.config/nixos/dotfiles/fcitx5/config",
        "~/.config/nixos/dotfiles/alacritty/alacritty.conf",
        "~/.config/nixos/dotfiles/tmux/.tmux.conf",
        "~/.config/nixos/dotfiles/helix/config.toml",
        "~/.config/nixos/dotfiles/fish/config.fish",
        "~/.config/nixos/dotfiles/yazi/keymap.toml",
        "~/.config/nixos/dotfiles/aichat/macros/yek.yaml",
        "~/.config/nixos/dotfiles/aichat/.env",
        "~/.config/nixos/scripts/quickshell__keybindhelper.qml"
    ]
    property string footerNote: "Also: Defaults from Helix/Neovim, Yazi, Lazygit, etc"
    property string footerNote2: "For less frequent functionality, consider the app launcher or running scripts from the shell prompt.\nSee ~/.config/nixos/scripts/**"

    property var columns: {
        var weights = keybindingGroups.map(function (group) {
            return group.keybindings.reduce(function (rows, bind) {
                return rows + bind.description.split("\n").length
            }, 2)
        })
        var total = weights.reduce(function (a, b) { return a + b }, 0)
        var wanted = Math.max(1, Math.ceil(total / maxRowsPerColumn))
        var packed = [[]]
        var used = 0
        for (var g = 0; g < keybindingGroups.length; g++) {
            if (packed.length < wanted && used > 0 && used + weights[g] / 2 > total / wanted) {
                packed.push([])
                used = 0
            }
            var cells = packed[packed.length - 1]
            var group = keybindingGroups[g]
            cells.push({ "kind": "header", "text": group.category, "spaced": used > 0 })
            for (var b = 0; b < group.keybindings.length; b++) {
                cells.push({ "kind": "key", "text": group.keybindings[b].key })
                cells.push({ "kind": "description", "text": group.keybindings[b].description })
            }
            used += weights[g]
        }
        return packed
    }

    property bool showKeybindings: false
    IpcHandler {
        target: "KeybindHelperHandler"

        function toggle(): void {
            root.showKeybindings = !root.showKeybindings
        }
    }

    PanelWindow {
        id: panel
        visible: root.showKeybindings
        screen: Quickshell.screens[0]
        WlrLayershell.layer: WlrLayer.Overlay
        anchors {
            right: true
            bottom: true
        }
        margins {
            right: 20
            bottom: 30
        }

        readonly property real fitScale: Math.min(1,
            (screen.width * root.maxWidthFraction - 2 * root.padding) / Math.max(1, content.implicitWidth),
            (screen.height * root.maxHeightFraction - 2 * root.padding) / Math.max(1, content.implicitHeight))
        implicitWidth: content.implicitWidth * fitScale + 2 * root.padding
        implicitHeight: content.implicitHeight * fitScale + 2 * root.padding
        color: "#E0000000"
        MouseArea {
            anchors.fill: parent
            onClicked: root.showKeybindings = false
        }
        ColumnLayout {
            id: content
            x: root.padding
            y: root.padding
            width: implicitWidth
            height: implicitHeight
            transformOrigin: Item.TopLeft
            scale: panel.fitScale
            spacing: 15

            // Title section
            Text {
                text: root.title
                color: "#FFFFFF"
                font.pointSize: 18
                font.bold: true
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#40FFFFFF"
            }

            // Main section
            RowLayout {
                spacing: 50
                Repeater {
                    model: root.columns
                    GridLayout {
                        required property var modelData
                        Layout.alignment: Qt.AlignTop
                        columns: 2
                        columnSpacing: 12
                        rowSpacing: 3
                        Repeater {
                            model: modelData
                            Text {
                                required property var modelData
                                text: modelData.text
                                color: modelData.kind === "header" ? "#66D9EF"
                                     : modelData.kind === "key" ? "#A6E22E"
                                     : "#F8F8F2"
                                font.pointSize: modelData.kind === "header" ? 12 : 9
                                font.bold: modelData.kind === "header"
                                font.family: modelData.kind === "key" ? "monospace" : "sans-serif"
                                Layout.columnSpan: modelData.kind === "header" ? 2 : 1
                                Layout.topMargin: modelData.spaced ? 12 : 0
                                Layout.alignment: Qt.AlignTop
                            }
                        }
                    }
                }
            }

            // Related files section
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 5
                spacing: 8
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: "#40FFFFFF"
                }
                Text {
                    text: "Related files (in " + root.sourceFilesRoot + "):"
                    color: "#FD971F"
                    font.pointSize: 10
                    font.bold: true
                }
                // Columns are added as needed; paths drop the shared root above.
                GridLayout {
                    flow: GridLayout.TopToBottom
                    rows: root.maxRelatedFileRows
                    columnSpacing: 30
                    rowSpacing: 4
                    Repeater {
                        model: root.sourceFiles
                        Text {
                            text: "• " + modelData.replace(root.sourceFilesRoot, "")
                            color: "#75715E"
                            font.pointSize: 9
                            font.family: "monospace"
                        }
                    }
                }
                Text {
                    text: root.footerNote
                    color: "#505050"
                    font.pointSize: 8
                    Layout.topMargin: 5
                    Layout.alignment: Qt.AlignLeft
                }
                Text {
                    text: root.footerNote2
                    color: "#505050"
                    font.pointSize: 8
                    Layout.topMargin: 2
                    Layout.alignment: Qt.AlignLeft
                }
            }
        }
    }
}
