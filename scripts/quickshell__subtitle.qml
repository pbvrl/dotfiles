#!/usr/bin/env -S quickshell -p

// Overlays a text. Useful for screen recordings.

// Requires:
//   quickshell

// WARNING: Had AI make it, have not checked it.

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: root
    
    property string subtitle: "Claude code notifications"
    
    Variants {
        model: Quickshell.screens
        PanelWindow {
            property var modelData
            screen: modelData
            anchors {
                bottom: true
                left: true
                right: true
            }
            margins.bottom: 30
            exclusiveZone: 0
            width: subtitleBox.implicitWidth
            height: subtitleBox.implicitHeight
            color: "transparent"
            mask: Region {}
            WlrLayershell.layer: WlrLayer.Overlay
            Rectangle {
                id: subtitleBox
                anchors.centerIn: parent
                implicitWidth: Math.min(screen.width * 0.8, subtitleLabel.implicitWidth + 40)
                implicitHeight: subtitleLabel.implicitHeight + 20
                color: "#80000000"
                Text {
                    id: subtitleLabel
                    anchors.centerIn: parent
                    text: root.subtitle
                    color: "#FFFFFF"
                    font.pointSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    width: Math.min(parent.width - 40, implicitWidth)
                }
            }
        }
    }
}
