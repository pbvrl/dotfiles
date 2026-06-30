// Desktop widget that displays the time, date, battery, cpu usage and whether notifications are in hidden mode

// Requires:
//   quickshell
//   upower
//   makoctl

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

ShellRoot {
    id: root
    property string currentTime: ""
    property string currentDayOfTheWeek: ""
    property string currentDay: ""
    property int batteryPct: -1
    property int cpuPct: -1
    property bool makoHidden: false
    property color defaultColor: "#a8a8a8"
    property color warningColor: "#ffaa00"
    property color criticalColor: "#ff4444"
    property string defaultFont: "monospace"
    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: {
            var now = new Date()
            root.currentTime = Qt.formatTime(now, "hh:mm")
            root.currentDayOfTheWeek = Qt.formatDate(now, "ddd")
            root.currentDay = Qt.formatDate(now, "dd")
            if (UPower.displayDevice.ready && UPower.displayDevice.percentage >= 0) {
                root.batteryPct = Math.round(UPower.displayDevice.percentage * 100)
            }
            cpuProcess.running = true
            makoProcess.running = true
        }
    }
    Process {
        id: cpuProcess
        command: ["sh", "-c", "top -bn1 | awk '/^%Cpu\\(s\\):/{ print int($2) }'"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                var usage = parseInt(data.trim())
                if (!isNaN(usage)) root.cpuPct = usage
            }
        }
    }
    Process {
        id: makoProcess
        command: ["makoctl", "mode"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                var mode = data.trim()
                root.makoHidden = (mode === "hidden")
            }
        }
    }
    Variants {
        model: Quickshell.screens
        PanelWindow {
            property var modelData
            screen: modelData
            anchors { right: true; bottom: true }
            margins { right: 3; bottom: 0 }
            implicitWidth: content.implicitWidth + 8
            implicitHeight: content.implicitHeight + 5
            color: "transparent"
            mask: Region {}
            RowLayout {
                id: content
                spacing: 15
                Column {
                    Layout.alignment: Qt.AlignHCenter
                    visible: root.makoHidden
                    Text {
                        text: "H"
                        color: root.warningColor
                        font { pointSize: 11; family: root.defaultFont }
                    }
                }
                Column {
                    Layout.alignment: Qt.AlignHCenter
                    Text {
                        text: root.currentTime
                        color: root.defaultColor
                        font { pointSize: 11; family: root.defaultFont }
                    }
                }
                Column {
                    Layout.alignment: Qt.AlignHCenter
                    Text {
                        text: root.currentDayOfTheWeek
                        color: root.defaultColor
                        font { pointSize: 11; family: root.defaultFont }
                    }
                }
                Column {
                    Layout.alignment: Qt.AlignHCenter
                    Text {
                        text: root.currentDay
                        color: root.defaultColor
                        font { pointSize: 11; family: root.defaultFont }
                    }
                }
                Column {
                    Layout.alignment: Qt.AlignHCenter
                    Text {
                        text: "CPU"
                        color: root.defaultColor
                        font { pointSize: 8; family: root.defaultFont }
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: root.cpuPct >= 0 ? root.cpuPct : "--"
                        color: root.cpuPct < 0 ? root.defaultColor :
                               root.cpuPct > 70 ? root.criticalColor :
                               root.cpuPct > 20 ? root.warningColor : root.defaultColor
                        font { pointSize: 8; family: root.defaultFont }
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                Column {
                    Layout.alignment: Qt.AlignHCenter
                    Text {
                        text: "BAT"
                        color: root.defaultColor
                        font { pointSize: 8; family: root.defaultFont }
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: root.batteryPct >= 0 ? root.batteryPct : "--"
                        color: root.batteryPct < 0 ? root.defaultColor :
                               root.batteryPct < 20 ? root.criticalColor :
                               root.batteryPct < 50 ? root.warningColor : root.defaultColor
                        font { pointSize: 8; family: root.defaultFont }
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        var now = new Date()
        root.currentTime = Qt.formatTime(now, "hh:mm")
        root.currentDayOfTheWeek = Qt.formatDate(now, "ddd")
        root.currentDay = Qt.formatDate(now, "dd")
        if (UPower.displayDevice.ready && UPower.displayDevice.percentage >= 0) {
            root.batteryPct = Math.round(UPower.displayDevice.percentage * 100)
        }
        cpuProcess.running = true
        makoProcess.running = true
    }
}
