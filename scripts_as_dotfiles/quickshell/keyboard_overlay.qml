import QtQuick
import Quickshell

Variants {
    id: overlay
    model: Quickshell.screens
    property string layer: "base"  // base layer name from kanata.kbd
    property color keyColor: "#252530"
    property color panelColor: "#e614141c"
    property color textColor: "#e0e0e6"
    property color dimColor: "#6a6a78"
    property color accentColor: "#7aa2f7"
    property color modColor: "#e0af68"
    property string fontFamily: "monospace"
    property int keySize: 44
    property int keySpacing: 5
    readonly property bool shifted: overlay.layer === "extrashift"
    // offset staggers the widget rows
    readonly property var rows: [
        { offset: 0,
          src:   "tab  q    w    e    r    t    y    u    i    o    p    [",
          base:  "tab  q    w    e    r    t    y    u    i    o    p    bspc",
          extra: ".    1    2    3    4    5    6    7    8    .    .    .",
          shift: ".    !    @    #    $    %    ^    &    *    .    .    ." },
        { offset: 14,
          src:   "caps a    s    d    f    g    h    j    k    l    ;    '",
          base:  "esc  a    s    d    f    g    h    j    k    l    :    ret",
          extra: ".    ⇧    -    '    /    =    ;    9    0    [    ]    .",
          shift: ".    .    <    .    >    .    .    (    )    {    }    ." },
        { offset: 32,
          src:   "lsft z    x    c    v    b    n    m    ,    .    /",
          base:  "lsft z    x    c    v    b    n    m    ,    .    /",
          extra: ".    .    _    \"   ?    +    `    \\   .    .    .",
          shift: ".    .    .    .    .    .    ~    |    .    .    ." }
    ].map(g => {
        const src = g.src.trim().split(/\s+/)
        const base = g.base.trim().split(/\s+/)
        const extra = g.extra.trim().split(/\s+/)
        const shift = g.shift.trim().split(/\s+/)
        return {
            offset: g.offset,
            keys: src.map((s, i) => ({ src: s, base: base[i], extra: extra[i], shift: shift[i] }))
        }
    })
    PanelWindow {
        property var modelData
        screen: modelData
        visible: overlay.layer === "extra" || overlay.shifted
        anchors { bottom: true }
        margins { bottom: 40 }
        exclusiveZone: 0
        color: "transparent"
        mask: Region {}
        implicitWidth: board.implicitWidth + 24
        implicitHeight: board.implicitHeight + 24
        Rectangle {
            anchors.fill: parent
            radius: 10
            color: overlay.panelColor
        }
        Column {
            id: board
            anchors.centerIn: parent
            spacing: overlay.keySpacing
            Text {
                text: overlay.shifted ? "extra + shift" : "extra"
                color: overlay.shifted ? overlay.modColor : overlay.accentColor
                font { pointSize: 8; family: overlay.fontFamily }
            }
            Repeater {
                model: overlay.rows
                Row {
                    required property var modelData
                    spacing: overlay.keySpacing
                    leftPadding: modelData.offset
                    Repeater {
                        model: parent.modelData.keys
                        Rectangle {
                            id: keycap
                            required property var modelData
                            readonly property string layered: overlay.shifted ? modelData.shift : modelData.extra
                            readonly property bool passthrough: keycap.layered === "."
                            readonly property string legend: keycap.passthrough ? modelData.base : keycap.layered
                            width: overlay.keySize
                            height: overlay.keySize
                            radius: 5
                            color: overlay.keyColor
                            opacity: keycap.passthrough ? 0.4 : 1.0
                            Text {
                                x: 4
                                y: 3
                                text: keycap.modelData.src
                                color: overlay.dimColor
                                font { pointSize: 6; family: overlay.fontFamily }
                            }
                            Text {
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: 3
                                text: keycap.legend
                                color: keycap.passthrough ? overlay.textColor
                                     : keycap.legend === "⇧" ? overlay.modColor : overlay.accentColor
                                font { pointSize: keycap.legend.length > 2 ? 8 : 15; family: overlay.fontFamily }
                            }
                        }
                    }
                }
            }
        }
    }
}
