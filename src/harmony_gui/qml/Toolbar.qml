import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes
import Harmony 1.0

ToolBar {
    id: control

    background: Rectangle {
        color: root.colorPanel
        border.color: root.colorBorder
        border.width: 1

        // Bottom border only shadow effect
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: root.colorBorder
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        spacing: 20

        // App Branding
        RowLayout {
            spacing: 8
            Rectangle {
                width: 24
                height: 24
                radius: 12
                color: root.colorAccent
                border.color: "#9b60ff"
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "H"
                    color: root.colorText
                    font.bold: true
                    font.pixelSize: 12
                }
            }
            Text {
                text: "HARMONY"
                color: root.colorText
                font.bold: true
                font.letterSpacing: 1.5
                font.pixelSize: 14
            }
        }

        // File Actions Panel
        RowLayout {
            spacing: 6

            // New Button
            Button {
                id: newBtn
                implicitWidth: 32
                implicitHeight: 32
                ToolTip.visible: hovered
                ToolTip.text: qsTr("New Project")
                background: Rectangle {
                    radius: 6
                    color: newBtn.hovered ? root.colorPanelLight : "transparent"
                    border.color: newBtn.hovered ? root.colorBorder : "transparent"
                }
                contentItem: Shape {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    ShapePath {
                        fillColor: newBtn.hovered ? root.colorAccentHover : root.colorText
                        strokeColor: "transparent"
                        PathSvg {
                            path: "M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zM6 20V4h7v5h5v11H6z"
                        }
                    }
                }
                onClicked: playback.createNewProject()
            }

            // Open Button
            Button {
                id: openBtn
                implicitWidth: 32
                implicitHeight: 32
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Open Project")
                background: Rectangle {
                    radius: 6
                    color: openBtn.hovered ? root.colorPanelLight : "transparent"
                    border.color: openBtn.hovered ? root.colorBorder : "transparent"
                }
                contentItem: Shape {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    ShapePath {
                        fillColor: openBtn.hovered ? root.colorAccentHover : root.colorText
                        strokeColor: "transparent"
                        PathSvg {
                            path: "M20 6h-8l-2-2H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2zm0 12H4V8h16v10z"
                        }
                    }
                }
                onClicked: openFileDialog.open()
            }

            // Save Button
            Button {
                id: saveBtn
                implicitWidth: 32
                implicitHeight: 32
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Save Project")
                background: Rectangle {
                    radius: 6
                    color: saveBtn.hovered ? root.colorPanelLight : "transparent"
                    border.color: saveBtn.hovered ? root.colorBorder : "transparent"
                }
                contentItem: Shape {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    ShapePath {
                        fillColor: saveBtn.hovered ? root.colorAccentHover : root.colorText
                        strokeColor: "transparent"
                        PathSvg {
                            path: "M17 3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V7l-4-4zm2 16H5V5h11.17L19 7.83V19zm-7-7c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3zM6 6h9v4H6V6z"
                        }
                    }
                }
                onClicked: {
                    if (playback.projectFileName === "") {
                        saveFileDialog.open()
                    } else {
                        playback.saveProject()
                    }
                }
            }

            // Save As Button
            Button {
                id: saveAsBtn
                implicitWidth: 32
                implicitHeight: 32
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Save Project As")
                background: Rectangle {
                    radius: 6
                    color: saveAsBtn.hovered ? root.colorPanelLight : "transparent"
                    border.color: saveAsBtn.hovered ? root.colorBorder : "transparent"
                }
                contentItem: Shape {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    ShapePath {
                        fillColor: saveAsBtn.hovered ? root.colorAccentHover : root.colorText
                        strokeColor: "transparent"
                        PathSvg {
                            path: "M12.9 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V9l-6-6zm6 16H5V5h7v5h5v9z"
                        }
                    }
                }
                onClicked: saveFileDialog.open()
            }
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // Transport Panel
        RowLayout {
            spacing: 6

            // Play Button
            Button {
                id: playBtn
                implicitWidth: 32
                implicitHeight: 32
                background: Rectangle {
                    radius: 6
                    color: playBtn.hovered ? root.colorPanelLight : "transparent"
                    border.color: playBtn.hovered ? root.colorBorder : "transparent"
                }
                contentItem: Shape {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    ShapePath {
                        fillColor: playback.isPlaying ? "#22c55e" : (playBtn.hovered ? "#22c55e" : root.colorText)
                        strokeColor: "transparent"
                        PathSvg {
                            path: "M8 5v14l11-7z"
                        }
                    }
                }
                Behavior on scale { NumberAnimation { duration: 100 } }
                onPressed: scale = 0.95
                onReleased: scale = 1.0
                onClicked: playback.play()
            }

            // Pause Button
            Button {
                id: pauseBtn
                implicitWidth: 32
                implicitHeight: 32
                background: Rectangle {
                    radius: 6
                    color: pauseBtn.hovered ? root.colorPanelLight : "transparent"
                    border.color: pauseBtn.hovered ? root.colorBorder : "transparent"
                }
                contentItem: Shape {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    ShapePath {
                        fillColor: playback.isPaused ? "#fbbf24" : (pauseBtn.hovered ? "#fbbf24" : root.colorText)
                        strokeColor: "transparent"
                        PathSvg {
                            path: "M6 19h4V5H6v14zm8-14v14h4V5h-4z"
                        }
                    }
                }
                onPressed: scale = 0.95
                onReleased: scale = 1.0
                onClicked: playback.pause()
            }

            // Stop Button
            Button {
                id: stopBtn
                implicitWidth: 32
                implicitHeight: 32
                background: Rectangle {
                    radius: 6
                    color: stopBtn.hovered ? root.colorPanelLight : "transparent"
                    border.color: stopBtn.hovered ? root.colorBorder : "transparent"
                }
                contentItem: Shape {
                    anchors.centerIn: parent
                    width: 14
                    height: 14
                    ShapePath {
                        fillColor: stopBtn.hovered ? "#ef4444" : root.colorText
                        strokeColor: "transparent"
                        PathSvg {
                            path: "M6 6h12v12H6z"
                        }
                    }
                }
                onPressed: scale = 0.95
                onReleased: scale = 1.0
                onClicked: playback.stop()
            }

            // Record Button
            Button {
                id: recBtn
                implicitWidth: 32
                implicitHeight: 32
                background: Rectangle {
                    radius: 6
                    color: recBtn.hovered ? root.colorPanelLight : "transparent"
                    border.color: recBtn.hovered ? root.colorBorder : "transparent"
                }
                contentItem: Shape {
                    anchors.centerIn: parent
                    width: 12
                    height: 12
                    ShapePath {
                        fillColor: recBtn.hovered ? "#ef4444" : "#b91c1c"
                        strokeColor: "transparent"
                        PathSvg {
                            path: "M12 2C6.47 2 2 6.47 2 12s6.47 10 10 10 10-6.47 10-10S17.53 2 12 2z"
                        }
                    }
                }
                onPressed: scale = 0.95
                onReleased: scale = 1.0
            }
        }

        // LCD Time Display
        Rectangle {
            width: 140
            height: 32
            color: "#0a0a0d"
            radius: 4
            border.color: root.colorBorder
            border.width: 1

            RowLayout {
                anchors.centerIn: parent
                spacing: 8
                Text {
                    text: playback.timePosition
                    color: "#00d2d3"
                    font.family: "Monospace"
                    font.pixelSize: 14
                    font.bold: true
                    style: Text.Outline
                    styleColor: "#005f5f"
                }
            }
        }

        // BPM & Info Control
        RowLayout {
            spacing: 5
            Text {
                text: "TEMPO"
                color: root.colorTextMuted
                font.pixelSize: 10
                font.bold: true
            }
            SpinBox {
                id: bpmSpinBox
                value: playback.tempo
                to: 999
                from: 20
                editable: true
                implicitWidth: 80
                implicitHeight: 32
                
                contentItem: TextInput {
                    text: bpmSpinBox.textFromValue(bpmSpinBox.value, bpmSpinBox.locale)
                    font.pixelSize: 12
                    color: root.colorText
                    selectionColor: root.colorAccent
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                }
                
                background: Rectangle {
                    color: root.colorPanelLight
                    border.color: root.colorBorder
                    radius: 4
                }

                onValueModified: {
                    playback.tempo = value
                }
            }
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // Oscilloscope / Visualizer
        RowLayout {
            spacing: 8
            Text {
                text: "OUT"
                color: root.colorTextMuted
                font.pixelSize: 10
                font.bold: true
            }
            Rectangle {
                width: 90
                height: 24
                color: "#0a0a0d"
                radius: 4
                border.color: root.colorBorder
                border.width: 1
                clip: true

                Canvas {
                    id: oscCanvas
                    anchors.fill: parent
                    anchors.margins: 1
                    property real phase: 0.0

                    Timer {
                        interval: 30
                        running: true
                        repeat: true
                        onTriggered: {
                            if (playback.isPlaying) {
                                oscCanvas.phase += 0.25
                                oscCanvas.requestPaint()
                            } else if (oscCanvas.phase > 0) {
                                oscCanvas.phase = 0.0
                                oscCanvas.requestPaint()
                            }
                        }
                    }

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.strokeStyle = "#22c55e"
                        ctx.lineWidth = 1.5
                        ctx.beginPath()

                        ctx.moveTo(0, height / 2)
                        for (var x = 0; x < width; x++) {
                            var y = height / 2
                            if (playback.isPlaying) {
                                var amp = (height / 2.5) * (0.8 + 0.2 * Math.sin(phase * 0.2))
                                y += Math.sin(x * 0.15 - phase) * Math.cos(x * 0.05 + phase * 0.1) * amp
                            }
                            ctx.lineTo(x, y)
                        }
                        ctx.stroke()
                    }
                }
            }
        }

        // System CPU Indicator
        RowLayout {
            spacing: 8
            Text {
                text: "CPU"
                color: root.colorTextMuted
                font.pixelSize: 10
                font.bold: true
            }
            ProgressBar {
                id: cpuMeter
                value: 0.15
                implicitWidth: 80
                implicitHeight: 6
                background: Rectangle {
                    color: root.colorBorder
                    radius: 3
                }
                contentItem: Item {
                    Rectangle {
                        width: cpuMeter.visualPosition * parent.width
                        height: parent.height
                        radius: 3
                        color: root.colorAccent
                    }
                }
            }
        }
    }
}
