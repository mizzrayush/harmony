import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes
import Harmony 1.0

Rectangle {
    id: bottomRoot
    color: root.colorPanel
    property int activeTab: 0 // Default to Piano Roll

    // Top border separator
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: root.colorBorder
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Tab Selector Header
        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: root.colorPanel
            border.color: root.colorBorder
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                spacing: 8

                Repeater {
                    model: ["Piano Roll", "FX Mixer", "Sampler"]
                    delegate: Button {
                        id: tabBtn
                        implicitWidth: 100
                        implicitHeight: 28

                        background: Rectangle {
                            color: bottomRoot.activeTab === index ? root.colorPanelLight : "transparent"
                            radius: 4
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width * 0.8
                                height: 2
                                color: root.colorAccent
                                visible: bottomRoot.activeTab === index
                            }
                        }

                        contentItem: Text {
                            text: modelData
                            color: bottomRoot.activeTab === index ? root.colorText : root.colorTextMuted
                            font.pixelSize: 11
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: bottomRoot.activeTab = index
                    }
                }
            }
        }

        // Active View Container
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: bottomRoot.activeTab

            // Page 0: Piano Roll (Interactive)
            RowLayout {
                spacing: 0

                property int stepWidth: 24
                property int rowHeight: 20
                property int totalSteps: 64
                property int totalKeys: 60 // C2 (36) to B6 (95)

                // Piano keys column (Scrolls synced with Note Grid)
                ScrollView {
                    id: pianoKeysScroll
                    width: 50
                    Layout.fillHeight: true
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                    clip: true

                    Column {
                        id: keysColumn
                        width: parent.width
                        y: noteGridScroll.contentY // Sync scroll Y position

                        Repeater {
                            model: 60 // 60 keys, from key 95 down to 36
                            delegate: Rectangle {
                                width: pianoKeysScroll.width
                                height: 20
                                color: root.colorBorder

                                // Determine if black key (notes: C#, D#, F#, G#, A# -> 1,3,6,8,10 in octave)
                                property int keyNum: 95 - index
                                property int noteInOctave: keyNum % 12
                                property bool isBlack: noteInOctave === 1 || noteInOctave === 3 || noteInOctave === 6 || noteInOctave === 8 || noteInOctave === 10

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.rightMargin: isBlack ? 16 : 0
                                    anchors.bottomMargin: 1
                                    color: isBlack ? "#18191d" : "#f1f2f6"
                                    radius: isBlack ? 2 : 0
                                }

                                Text {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: {
                                        // Label C notes
                                        if (noteInOctave === 0) {
                                            return "C" + Math.floor(keyNum / 12 - 1)
                                        }
                                        return ""
                                    }
                                    color: isBlack ? "#ffffff" : "#4a5568"
                                    font.pixelSize: 8
                                    font.bold: true
                                }
                            }
                        }
                    }
                }

                // Note Grid Area
                ScrollView {
                    id: noteGridScroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    // Inside note grid layout
                    Item {
                        id: noteGrid
                        width: 64 * 24 // totalSteps * stepWidth
                        height: 60 * 20 // totalKeys * rowHeight

                        // Dynamic grid separator canvas
                        Canvas {
                            id: gridCanvas
                            anchors.fill: parent
                            
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                ctx.lineWidth = 1

                                // Horizontal notes separations
                                for (var y = 0; y <= height; y += 20) {
                                    ctx.strokeStyle = "#1b1b1f"
                                    ctx.beginPath()
                                    ctx.moveTo(0, y)
                                    ctx.lineTo(width, y)
                                    ctx.stroke()
                                }

                                // Vertical bars separations
                                for (var x = 0; x <= width; x += 24) {
                                    var stepIndex = x / 24
                                    if (stepIndex % 16 === 0) {
                                        ctx.strokeStyle = "#4b4b54" // Bar
                                        ctx.lineWidth = 1.5
                                    } else if (stepIndex % 4 === 0) {
                                        ctx.strokeStyle = "#2d2d35" // Beat
                                        ctx.lineWidth = 1.0
                                    } else {
                                        ctx.strokeStyle = "#1a1b20" // Step
                                        ctx.lineWidth = 0.5
                                    }
                                    ctx.beginPath()
                                    ctx.moveTo(x, 0)
                                    ctx.lineTo(x, height)
                                    ctx.stroke()
                                }
                            }
                        }

                        // Grid interaction mouse area
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            onDoubleClicked: (mouse) => {
                                var stepX = Math.floor(mouse.x / 24)
                                var keyY = Math.floor(mouse.y / 20)
                                var newKey = 95 - keyY
                                var startTick = stepX * 12
                                globalNotePatternModel.addNote(newKey, startTick, 48, 0.8) // 1 beat default
                            }
                        }

                        // Notes Repeater
                        Repeater {
                            model: globalNotePatternModel
                            delegate: Rectangle {
                                id: noteRect
                                x: (model.startTick / 12) * 24
                                y: (95 - model.noteKey) * 20
                                width: Math.max(12, (model.lengthTicks / 12) * 24)
                                height: 18
                                border.color: Qt.lighter(root.colorAccent, 1.2)
                                border.width: 1
                                radius: 3
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#b68eff" }
                                    GradientStop { position: 1.0; color: "#7f39fb" }
                                }

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: model.noteName
                                    color: "#ffffff"
                                    font.pixelSize: 8
                                    font.bold: true
                                    visible: parent.width > 20
                                }

                                // Drag to move notes
                                MouseArea {
                                    anchors.fill: parent
                                    drag.target: parent
                                    drag.axis: Drag.XAndYAxis
                                    drag.minimumX: 0
                                    drag.maximumX: noteGrid.width - noteRect.width
                                    drag.minimumY: 0
                                    drag.maximumY: noteGrid.height - noteRect.height
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                                    property int startX: 0
                                    property int startY: 0

                                    onPressed: (mouse) => {
                                        startX = noteRect.x
                                        startY = noteRect.y
                                    }

                                    onReleased: (mouse) => {
                                        if (drag.active) {
                                            var stepX = Math.round(noteRect.x / 24)
                                            var keyY = Math.round(noteRect.y / 20)
                                            var newKey = 95 - keyY
                                            var newTick = Math.max(0, stepX * 12)
                                            globalNotePatternModel.moveNote(model.noteIndex, newKey, newTick)
                                        } else {
                                            if (mouse.button === Qt.RightButton) {
                                                globalNotePatternModel.removeNote(model.noteIndex)
                                            }
                                        }
                                    }
                                }

                                // Resize handle
                                Rectangle {
                                    width: 6
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    anchors.right: parent.right
                                    color: "transparent"

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.SizeHorCursor
                                        drag.target: parent
                                        drag.axis: Drag.XAxis

                                        property int startWidth: 0
                                        onPressed: (mouse) => {
                                            startWidth = noteRect.width
                                        }

                                        onPositionChanged: (mouse) => {
                                            if (drag.active) {
                                                var delta = mouse.x
                                                var newWidth = Math.max(12, noteRect.width + delta)
                                                noteRect.width = newWidth
                                            }
                                        }

                                        onReleased: (mouse) => {
                                            var finalWidthSteps = Math.round(noteRect.width / 24)
                                            if (finalWidthSteps < 1) finalWidthSteps = 1
                                            var newLengthTicks = finalWidthSteps * 12
                                            globalNotePatternModel.resizeNote(model.noteIndex, newLengthTicks)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Page 1: FX Mixer View
            RowLayout {
                spacing: 8
                anchors.margins: 12

                ListView {
                    id: mixerListView
                    orientation: ListView.Horizontal
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8
                    model: globalMixerModel

                    delegate: Rectangle {
                        width: 95
                        height: mixerListView.height
                        color: root.colorPanelLight
                        border.color: root.colorBorder
                        radius: 4

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 6

                            Text {
                                text: model.channelName
                                color: root.colorText
                                font.pixelSize: 10
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            // Peak Meter
                            RowLayout {
                                Layout.fillHeight: true
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 6

                                // Level slider fader
                                Slider {
                                    id: fader
                                    value: model.channelVolume
                                    orientation: Qt.Vertical
                                    Layout.fillHeight: true
                                    background: Rectangle {
                                        width: 4
                                        color: root.colorBorder
                                        radius: 2
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    onMoved: {
                                        model.channelVolume = value
                                    }
                                }

                                // VU Meter Led Bar (Left Channel)
                                Rectangle {
                                    width: 4
                                    Layout.fillHeight: true
                                    color: root.colorBorder
                                    radius: 1

                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        width: parent.width
                                        height: parent.height * Math.min(1.0, Math.max(0.0, model.peakLeft))
                                        radius: 1
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: "#e84118" } // Red peak
                                            GradientStop { position: 0.2; color: "#fbc531" } // Yellow mid
                                            GradientStop { position: 0.8; color: "#4cd137" } // Green safe
                                        }
                                    }
                                }

                                // VU Meter Led Bar (Right Channel)
                                Rectangle {
                                    width: 4
                                    Layout.fillHeight: true
                                    color: root.colorBorder
                                    radius: 1

                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        width: parent.width
                                        height: parent.height * Math.min(1.0, Math.max(0.0, model.peakRight))
                                        radius: 1
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: "#e84118" } // Red peak
                                            GradientStop { position: 0.2; color: "#fbc531" } // Yellow mid
                                            GradientStop { position: 0.8; color: "#4cd137" } // Green safe
                                        }
                                    }
                                }
                            }

                            Text {
                                text: qsTr("%1 dB").arg((fader.value * 12 - 12).toFixed(1))
                                color: root.colorTextMuted
                                font.pixelSize: 9
                                horizontalAlignment: Text.AlignHCenter
                                Layout.fillWidth: true
                            }
                        }
                    }

                    footer: Rectangle {
                        width: 95
                        height: mixerListView.height
                        color: "transparent"

                        Button {
                            id: addMixerBtn
                            anchors.fill: parent
                            anchors.margins: 4
                            background: Rectangle {
                                color: addMixerBtn.hovered ? root.colorPanelLight : "transparent"
                                border.color: addMixerBtn.hovered ? root.colorAccent : root.colorBorder
                                border.width: 1
                                radius: 6
                            }
                            contentItem: ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                Text {
                                    text: "+"
                                    color: addMixerBtn.hovered ? root.colorAccent : root.colorTextMuted
                                    font.pixelSize: 24
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: "Add Channel"
                                    color: root.colorTextMuted
                                    font.pixelSize: 9
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.fillWidth: true
                                }
                            }
                            onClicked: globalMixerModel.addChannel()
                        }
                    }
                }
            }

            // Page 2: Sampler View (Renovated ADSR, Filters and Waveform)
            ColumnLayout {
                anchors.margins: 12
                spacing: 12

                // Waveform Rendering
                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    color: root.colorBg
                    border.color: root.colorBorder
                    radius: 6

                    Text {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.margins: 8
                        text: "Instrument Waveform Engine (Dynamic Output)"
                        color: root.colorText
                        font.pixelSize: 10
                    }

                    Canvas {
                        id: waveCanvas
                        anchors.fill: parent
                        anchors.topMargin: 24
                        anchors.bottomMargin: 8
                        
                        property real phase: 0.0
                        
                        // Slowly animate wave on play
                        Timer {
                            interval: 30
                            running: true
                            repeat: true
                            onTriggered: {
                                if (playback.isPlaying) {
                                    waveCanvas.phase += 0.2
                                    waveCanvas.requestPaint()
                                }
                            }
                        }

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            ctx.strokeStyle = root.colorAccent
                            ctx.lineWidth = 2
                            ctx.beginPath()

                            // Draw a beautiful synth sine/saw waveform modulated by envelopes
                            var att = globalInstrumentControlModel.volumeAttack
                            var dec = globalInstrumentControlModel.volumeDecay
                            var sus = globalInstrumentControlModel.volumeSustain
                            var rel = globalInstrumentControlModel.volumeRelease

                            ctx.moveTo(0, height / 2)
                            for (var x = 0; x < width; x++) {
                                var factor = Math.sin(x * 0.05 - phase)
                                // Modulate by Cutoff/Resonance settings
                                var cut = globalInstrumentControlModel.filterCutoff
                                var res = globalInstrumentControlModel.filterResonance
                                var amp = (height / 3) * (0.3 + cut * 0.7)
                                if (x * 0.1 > phase) {
                                    amp = amp * Math.exp(-(x * 0.005))
                                }
                                var y = height / 2 + Math.sin(x * (0.05 + res * 0.05) - phase) * amp
                                ctx.lineTo(x, y)
                            }
                            ctx.stroke()
                        }
                    }
                }

                // Envelope & Filter Controls
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20
                    Layout.alignment: Qt.AlignHCenter

                    // Volume Envelope ADSR Panel
                    Rectangle {
                        color: root.colorPanelLight
                        radius: 8
                        border.color: root.colorBorder
                        border.width: 1
                        implicitWidth: 260
                        implicitHeight: 110

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            Text {
                                text: "VOLUME ENVELOPE (ADSR)"
                                color: root.colorText
                                font.pixelSize: 10
                                font.bold: true
                                Layout.alignment: Qt.AlignLeft
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                Layout.alignment: Qt.AlignHCenter

                                // Attack
                                ColumnLayout {
                                    spacing: 4
                                    Text { text: "ATTACK"; color: root.colorTextMuted; font.pixelSize: 8; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                                    Dial {
                                        id: attDial
                                        value: globalInstrumentControlModel.volumeAttack
                                        implicitWidth: 42; implicitHeight: 42
                                        onMoved: globalInstrumentControlModel.volumeAttack = value
                                        
                                        background: Rectangle {
                                            width: 42; height: 42; radius: 21; color: root.colorBg; border.color: attDial.hovered ? root.colorAccent : root.colorBorder; border.width: 1.5
                                        }
                                        handle: Rectangle {
                                            id: attHandle
                                            x: 21 - width / 2
                                            y: 21 - height / 2
                                            width: 6; height: 6; radius: 3; color: root.colorAccent
                                            transform: [
                                                Translate { y: -12 },
                                                Rotation { angle: attDial.angle; origin.x: attHandle.width / 2; origin.y: attHandle.height / 2 + 12 }
                                            ]
                                        }
                                    }
                                }

                                // Decay
                                ColumnLayout {
                                    spacing: 4
                                    Text { text: "DECAY"; color: root.colorTextMuted; font.pixelSize: 8; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                                    Dial {
                                        id: decDial
                                        value: globalInstrumentControlModel.volumeDecay
                                        implicitWidth: 42; implicitHeight: 42
                                        onMoved: globalInstrumentControlModel.volumeDecay = value
                                        
                                        background: Rectangle {
                                            width: 42; height: 42; radius: 21; color: root.colorBg; border.color: decDial.hovered ? root.colorAccent : root.colorBorder; border.width: 1.5
                                        }
                                        handle: Rectangle {
                                            id: decHandle
                                            x: 21 - width / 2
                                            y: 21 - height / 2
                                            width: 6; height: 6; radius: 3; color: root.colorAccent
                                            transform: [
                                                Translate { y: -12 },
                                                Rotation { angle: decDial.angle; origin.x: decHandle.width / 2; origin.y: decHandle.height / 2 + 12 }
                                            ]
                                        }
                                    }
                                }

                                // Sustain
                                ColumnLayout {
                                    spacing: 4
                                    Text { text: "SUSTAIN"; color: root.colorTextMuted; font.pixelSize: 8; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                                    Dial {
                                        id: susDial
                                        value: globalInstrumentControlModel.volumeSustain
                                        implicitWidth: 42; implicitHeight: 42
                                        onMoved: globalInstrumentControlModel.volumeSustain = value
                                        
                                        background: Rectangle {
                                            width: 42; height: 42; radius: 21; color: root.colorBg; border.color: susDial.hovered ? root.colorAccent : root.colorBorder; border.width: 1.5
                                        }
                                        handle: Rectangle {
                                            id: susHandle
                                            x: 21 - width / 2
                                            y: 21 - height / 2
                                            width: 6; height: 6; radius: 3; color: root.colorAccent
                                            transform: [
                                                Translate { y: -12 },
                                                Rotation { angle: susDial.angle; origin.x: susHandle.width / 2; origin.y: susHandle.height / 2 + 12 }
                                            ]
                                        }
                                    }
                                }

                                // Release
                                ColumnLayout {
                                    spacing: 4
                                    Text { text: "RELEASE"; color: root.colorTextMuted; font.pixelSize: 8; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                                    Dial {
                                        id: relDial
                                        value: globalInstrumentControlModel.volumeRelease
                                        implicitWidth: 42; implicitHeight: 42
                                        onMoved: globalInstrumentControlModel.volumeRelease = value
                                        
                                        background: Rectangle {
                                            width: 42; height: 42; radius: 21; color: root.colorBg; border.color: relDial.hovered ? root.colorAccent : root.colorBorder; border.width: 1.5
                                        }
                                        handle: Rectangle {
                                            id: relHandle
                                            x: 21 - width / 2
                                            y: 21 - height / 2
                                            width: 6; height: 6; radius: 3; color: root.colorAccent
                                            transform: [
                                                Translate { y: -12 },
                                                Rotation { angle: relDial.angle; origin.x: relHandle.width / 2; origin.y: relHandle.height / 2 + 12 }
                                            ]
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Separation Line
                    Rectangle {
                        width: 1
                        height: 90
                        color: root.colorBorder
                    }

                    // Analog Filter Panel
                    Rectangle {
                        color: root.colorPanelLight
                        radius: 8
                        border.color: root.colorBorder
                        border.width: 1
                        implicitWidth: 230
                        implicitHeight: 110

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            Text {
                                text: "ANALOG FILTER"
                                color: root.colorText
                                font.pixelSize: 10
                                font.bold: true
                                Layout.alignment: Qt.AlignLeft
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 14
                                Layout.alignment: Qt.AlignHCenter

                                // Filter Enabled CheckBox
                                ColumnLayout {
                                    spacing: 4
                                    Text { text: "ENABLED"; color: root.colorTextMuted; font.pixelSize: 8; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                                    CheckBox {
                                        id: filterEnableBox
                                        checked: globalInstrumentControlModel.filterEnabled
                                        onCheckedChanged: globalInstrumentControlModel.filterEnabled = checked
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }

                                // Cutoff
                                ColumnLayout {
                                    spacing: 4
                                    Text { text: "CUTOFF"; color: root.colorTextMuted; font.pixelSize: 8; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                                    Dial {
                                        id: cutDial
                                        value: globalInstrumentControlModel.filterCutoff
                                        implicitWidth: 42; implicitHeight: 42
                                        onMoved: globalInstrumentControlModel.filterCutoff = value
                                        
                                        background: Rectangle {
                                            width: 42; height: 42; radius: 21; color: root.colorBg; border.color: cutDial.hovered ? root.colorAccent : root.colorBorder; border.width: 1.5
                                        }
                                        handle: Rectangle {
                                            id: cutHandle
                                            x: 21 - width / 2
                                            y: 21 - height / 2
                                            width: 6; height: 6; radius: 3; color: root.colorAccent
                                            transform: [
                                                Translate { y: -12 },
                                                Rotation { angle: cutDial.angle; origin.x: cutHandle.width / 2; origin.y: cutHandle.height / 2 + 12 }
                                            ]
                                        }
                                    }
                                }

                                // Resonance
                                ColumnLayout {
                                    spacing: 4
                                    Text { text: "RESONANCE"; color: root.colorTextMuted; font.pixelSize: 8; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                                    Dial {
                                        id: resDial
                                        value: globalInstrumentControlModel.filterResonance
                                        implicitWidth: 42; implicitHeight: 42
                                        onMoved: globalInstrumentControlModel.filterResonance = value
                                        
                                        background: Rectangle {
                                            width: 42; height: 42; radius: 21; color: root.colorBg; border.color: resDial.hovered ? root.colorAccent : root.colorBorder; border.width: 1.5
                                        }
                                        handle: Rectangle {
                                            id: resHandle
                                            x: 21 - width / 2
                                            y: 21 - height / 2
                                            width: 6; height: 6; radius: 3; color: root.colorAccent
                                            transform: [
                                                Translate { y: -12 },
                                                Rotation { angle: resDial.angle; origin.x: resHandle.width / 2; origin.y: resHandle.height / 2 + 12 }
                                            ]
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
