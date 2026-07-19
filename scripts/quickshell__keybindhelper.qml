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
    property var widgetWidth: 0.4
    property var widgetHeight: 0.95
    property var maxKeybindsPerColumn: 30
    property var title: "Keybind helper"
    property var keybindingGroups: [
        {
            "category": "Keyboard remapper - Kanata",
            "keybindings": [
                { "key": "", "description": "Caps --> Esc" },
                { "key": "", "description": "Right Alt --> Ctrl" },
                { "key": "", "description": "' --> Enter" },
                { "key": "", "description": "[ --> Backspace" },
                { "key": "", "description": "Super+asdfg --> Super+1-5" },
                { "key": "; (Hold)+hjkl", "description": "Arrow keys" },
                { "key": "; (Hold)+...", "description": "Symbols, numbers layer" },
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
    property var sourceFiles: [
        "~/.config/nixos/dotfiles/kanata/kanata.kbd",
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
    
    property var numColumns: {
        var totalKeybindings = 0
        for (var i = 0; i < keybindingGroups.length; i++) {
            totalKeybindings += keybindingGroups[i].keybindings.length
        }
        return Math.max(1, Math.ceil(totalKeybindings / maxKeybindsPerColumn))
    }
    property var columnDistributions: {
        var columns = []
        for (var c = 0; c < numColumns; c++) {
            columns.push([])
        }
        var currentColumn = 0
        var currentColumnItems = 0
        for (var i = 0; i < keybindingGroups.length; i++) {
            var category = keybindingGroups[i]
            var categoryItems = category.keybindings.length
            if (currentColumnItems + categoryItems > maxKeybindsPerColumn && 
                columns[currentColumn].length > 0 && currentColumn < numColumns - 1) {
                currentColumn++
                currentColumnItems = 0
            }
            columns[currentColumn].push(i)
            currentColumnItems += categoryItems
        }
        return columns
    }
    
    // Global toggle state
    property bool showKeybindings: false
    IpcHandler {
        target: "KeybindHelperHandler"
        
        function toggle(): void {
            root.showKeybindings = !root.showKeybindings
        }
    }
    
    PanelWindow {
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
        implicitWidth: screen.width * widgetWidth
        implicitHeight: screen.height * widgetHeight
        color: "#E0000000"
        MouseArea {
            anchors.fill: parent
            onClicked: root.showKeybindings = false
        }
        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // Title section
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: title
                    color: "#FFFFFF"
                    font.pointSize: 18
                    font.bold: true
                    Layout.fillWidth: true
                }
            }
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#40FFFFFF"
            }
            
            // Main section
            RowLayout {
                Layout.fillWidth: false
                Layout.fillHeight: false
                spacing: 50
                Repeater {
                    model: root.numColumns
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        spacing: 15
                        Repeater {
                            model: root.columnDistributions[index]
                            ColumnLayout {
                                property var groupData: root.keybindingGroups[modelData]
                                spacing: 6
                                Text {
                                    text: groupData.category
                                    color: "#66D9EF"
                                    font.pointSize: 12
                                    font.bold: true
                                }
                                Repeater {
                                    model: groupData.keybindings
                                    RowLayout {
                                        property var keybinding: modelData
                                        Layout.fillWidth: true
                                        spacing: 8
                                        Text {
                                            text: keybinding.key
                                            color: "#A6E22E"
                                            font.pointSize: 9
                                            font.family: "monospace"
                                            Layout.preferredWidth: 100
                                        }
                                        Text {
                                            text: keybinding.description
                                            color: "#F8F8F2"
                                            font.pointSize: 9
                                            Layout.fillWidth: true
                                            wrapMode: Text.WordWrap
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Related files section
            ColumnLayout {
                spacing: 8
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#40FFFFFF"
                }
                Text {
                    text: "Related files:"
                    color: "#FD971F"
                    font.pointSize: 10
                    font.bold: true
                }
                GridLayout {
                    Layout.fillWidth: false
                    columns: 2
                    rows: Math.ceil(root.sourceFiles.length / 2)
                    flow: GridLayout.TopToBottom
                    columnSpacing: 20
                    rowSpacing: 3
                    Repeater {
                        model: root.sourceFiles
                        Text {
                            text: "• " + modelData
                            color: "#75715E"
                            font.pointSize: 9
                            font.family: "monospace"
                            Layout.fillWidth: true
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
