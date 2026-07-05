import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes
import Harmony 1.0

ToolBar {
    id: control

    PlaybackController {
        id: playback
    }

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
