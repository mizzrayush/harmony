import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Harmony

Rectangle {
    id: bottomRoot
    color: root.colorPanel

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

                property int activeTab: 1 // Default to FX Mixer

                Repeater {
                    model: ["Piano Roll", "FX Mixer", "Sampler"]
                    delegate: Button {
                        id: tabBtn
                        implicitWidth: 100
                        implicitHeight: 28

                        background: Rectangle {
                            color: parent.parent.activeTab === index ? root.colorPanelLight : "transparent"
                            radius: 4
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width * 0.8
                                height: 2
                                color: root.colorAccent
                                visible: parent.parent.parent.activeTab === index
                            }
                        }

                        contentItem: Text {
                            text: modelData
                            color: parent.parent.parent.activeTab === index ? root.colorText : root.colorTextMuted
                            font.pixelSize: 11
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: parent.parent.activeTab = index
                    }
                }
            }
        }

        // Active View Container
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: bottomRoot.children[1].children[0].children[0].activeTab // Bind stack layout index to active tab

            // Page 0: Piano Roll Mock
            RowLayout {
                spacing: 0

                // Piano keys column
                Rectangle {
                    width: 45
                    Layout.fillHeight: true
                    color: root.colorPanelLight
                    border.color: root.colorBorder
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 2
                        anchors.margins: 4
                        Repeater {
                            model: 6
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: 24
                                color: (index % 2 === 0) ? "#ffffff" : "#1e1e24"
                                border.color: root.colorBorder
                                radius: 2
                                Text {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "C" + (5 - index)
                                    color: (index % 2 === 0) ? "#000000" : "#ffffff"
                                    font.pixelSize: 8
                                    font.bold: true
                                }
                            }
                        }
                    }
                }

                // Note Grid
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        color: root.colorBg

                        // Grid lines
                        Grid {
                            columns: 16
                            rows: 6
                            spacing: 1
                            anchors.fill: parent

                            Repeater {
                                model: 96
                                delegate: Rectangle {
                                    width: 48
                                    height: 24
                                    color: root.colorPanel
                                }
                            }
                        }

                        // Mock Midi Notes
                        Rectangle { x: 50; y: 28; width: 90; height: 16; radius: 3; color: root.colorAccent; border.color: "#9b60ff" }
                        Rectangle { x: 150; y: 52; width: 60; height: 16; radius: 3; color: root.colorAccent; border.color: "#9b60ff" }
                        Rectangle { x: 220; y: 4; width: 120; height: 16; radius: 3; color: root.colorAccent; border.color: "#9b60ff" }
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
                }
            }

            // Page 2: Sampler View
            ColumnLayout {
                anchors.margins: 12
                spacing: 12

                // Waveform Mock
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
                        text: "Sample: Kick_Deep.wav (44.1kHz, 16bit, Mono)"
                        color: root.colorText
                        font.pixelSize: 10
                    }

                    // A mock wave path
                    Path {
                        // Drawing waveform lines using Canvas or simple visual elements is fine, we can use a mockup gradient
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: 24
                        anchors.bottomMargin: 8
                        color: "transparent"
                        
                        Row {
                            anchors.fill: parent
                            spacing: 1
                            Repeater {
                                model: 50
                                delegate: Rectangle {
                                    width: parent.width / 50 - 1
                                    height: (Math.sin(index * 0.2) * 0.7 + 0.3) * parent.height
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: root.colorAccent
                                    opacity: 0.7
                                }
                            }
                        }
                    }
                }

                // Envelope Controls (ADSR Knobs)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20
                    Layout.alignment: Qt.AlignHCenter

                    Repeater {
                        model: [
                            { name: "ATTACK", val: 0.1 },
                            { name: "DECAY", val: 0.3 },
                            { name: "SUSTAIN", val: 0.8 },
                            { name: "RELEASE", val: 0.5 }
                        ]
                        delegate: ColumnLayout {
                            spacing: 4
                            Text {
                                text: modelData.name
                                color: root.colorTextMuted
                                font.pixelSize: 9
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Dial {
                                value: modelData.val
                                implicitWidth: 44
                                implicitHeight: 44
                                background: Rectangle {
                                    width: 44
                                    height: 44
                                    radius: 22
                                    color: root.colorPanelLight
                                    border.color: root.colorBorder
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
