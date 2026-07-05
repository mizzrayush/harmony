import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Harmony

Rectangle {
    id: timelineRoot
    color: root.colorBg

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Timeline Ruler Header (Bar Numbers)
        Rectangle {
            Layout.fillWidth: true
            height: 28
            color: root.colorPanel
            border.color: root.colorBorder
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 200 // Offset for track headers
                spacing: 0

                Repeater {
                    model: 12
                    delegate: Rectangle {
                        width: 80
                        height: 28
                        color: "transparent"
                        border.color: root.colorBorder
                        border.width: 0.5
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 5
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Bar %1").arg(index + 1)
                            color: root.colorTextMuted
                            font.pixelSize: 9
                            font.bold: true
                        }
                    }
                }
            }
        }

        // Track List and Arrangement View
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: trackListView
                anchors.fill: parent
                spacing: 4
                model: globalTrackListModel

                delegate: Rectangle {
                    id: trackRowItem
                    width: trackListView.width
                    height: 60
                    color: root.colorPanel
                    border.color: root.colorBorder
                    border.width: 0.5
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        // Left Side: Track Headers (Controls)
                        Rectangle {
                            width: 200
                            height: parent.height
                            color: root.colorPanelLight
                            radius: 4

                            Rectangle {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: 1
                                color: root.colorBorder
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 6
                                spacing: 4

                                RowLayout {
                                    spacing: 6
                                    Text {
                                        text: model.trackType === 0 ? "🎹" : "🔊"
                                        font.pixelSize: 12
                                    }
                                    Text {
                                        text: model.trackName
                                        color: root.colorText
                                        font.bold: true
                                        font.pixelSize: 11
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                }

                                RowLayout {
                                    spacing: 4

                                    // Mute Button
                                    Button {
                                        id: muteBtn
                                        implicitWidth: 22
                                        implicitHeight: 18
                                        checkable: true
                                        checked: model.isMuted
                                        background: Rectangle {
                                            color: muteBtn.checked ? "#e84118" : root.colorPanel
                                            radius: 3
                                            border.color: root.colorBorder
                                        }
                                        contentItem: Text {
                                            text: "M"
                                            color: muteBtn.checked ? "#ffffff" : root.colorTextMuted
                                            font.pixelSize: 9
                                            font.bold: true
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: globalTrackListModel.toggleMute(index)
                                    }

                                    // Solo Button
                                    Button {
                                        id: soloBtn
                                        implicitWidth: 22
                                        implicitHeight: 18
                                        checkable: true
                                        checked: model.isSolo
                                        background: Rectangle {
                                            color: soloBtn.checked ? "#fbc531" : root.colorPanel
                                            radius: 3
                                            border.color: root.colorBorder
                                        }
                                        contentItem: Text {
                                            text: "S"
                                            color: soloBtn.checked ? "#000000" : root.colorTextMuted
                                            font.pixelSize: 9
                                            font.bold: true
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: globalTrackListModel.toggleSolo(index)
                                    }

                                    // Volume Slider Mock
                                    Slider {
                                        value: 0.8
                                        implicitWidth: 100
                                        implicitHeight: 18
                                        background: Rectangle {
                                            height: 4
                                            color: root.colorBorder
                                            radius: 2
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }
                            }
                        }

                        // Right Side: Clips & Grid
                        Item {
                            Layout.fillWidth: true
                            height: parent.height

                            // Visual Grid Background Lines
                            RowLayout {
                                anchors.fill: parent
                                spacing: 0
                                Repeater {
                                    model: 12
                                    delegate: Rectangle {
                                        width: 80
                                        height: parent.parent.height
                                        color: "transparent"
                                        border.color: "#1e1e24"
                                        border.width: 0.5
                                    }
                                }
                            }

                            // Interactive Clip rectangle
                            Rectangle {
                                x: 40
                                y: 8
                                width: 240
                                height: 44
                                radius: 6
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: model.trackColor }
                                    GradientStop { position: 1.0; color: Qt.darker(model.trackColor, 1.2) }
                                }
                                border.color: Qt.lighter(model.trackColor, 1.2)
                                border.width: 1

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: model.trackName + " Clip"
                                    color: root.colorText
                                    font.bold: true
                                    font.pixelSize: 10
                                    style: Text.Outline
                                    styleColor: "#50000000"
                                }

                                // Interactive hover effect
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.opacity = 0.9
                                    onExited: parent.opacity = 1.0
                                }
                            }
                        }
                    }

                    // Context Menu for deleting track
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked: trackContextMenu.open()
                    }

                    Menu {
                        id: trackContextMenu
                        MenuItem {
                            text: "Delete track"
                            onTriggered: globalTrackListModel.deleteTrack(index)
                        }
                    }
                }
            }
        }
    }
}
