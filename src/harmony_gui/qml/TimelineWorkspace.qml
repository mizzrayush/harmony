import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes
import Harmony

Rectangle {
    id: timelineRoot
    color: root.colorBg

    readonly property int ticksPerBar: 192
    readonly property int barWidth: 80

    function tickToX(ticks) {
        return (ticks * barWidth) / ticksPerBar
    }

    function xToTick(x) {
        return Math.round((x * ticksPerBar) / barWidth)
    }

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
                    color: root.selectedTrackIndex === index ? root.colorPanelLight : root.colorPanel
                    border.color: root.selectedTrackIndex === index ? root.colorAccent : root.colorBorder
                    border.width: root.selectedTrackIndex === index ? 1.5 : 0.5
                    radius: 4

                    property string trackColorHex: model.trackColor
                    property var trackPtr: model.trackId
                    property int trackIndex: index

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        // Left Side: Track Headers (Controls)
                        Rectangle {
                            width: 200
                            height: parent.height
                            color: root.selectedTrackIndex === index ? Qt.lighter(root.colorPanelLight, 1.1) : root.colorPanelLight
                            radius: 4

                            TapHandler {
                                onPressedChanged: {
                                    if (pressed) {
                                        root.selectedTrackIndex = trackRowItem.trackIndex
                                    }
                                }
                            }

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
                                    Shape {
                                        width: 14
                                        height: 14
                                        ShapePath {
                                            fillColor: root.selectedTrackIndex === index ? root.colorAccent : root.colorTextMuted
                                            strokeColor: "transparent"
                                            PathSvg {
                                                path: model.trackType === 0 
                                                    ? "M20 3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-9 12.5h-1.5V5h1.5v10.5zm3 0h-1.5V5h1.5v10.5zm3 0h-1.5V5h1.5v10.5z"
                                                    : "M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15.5h-2v-2h2v2zm0-4h-2V7h2v6.5z"
                                            }
                                        }
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
                                    spacing: 6

                                    // Mute Button (SVG)
                                    Button {
                                        id: muteBtn
                                        implicitWidth: 24
                                        implicitHeight: 20
                                        checkable: true
                                        checked: model.isMuted
                                        background: Rectangle {
                                            color: muteBtn.checked ? "#ef4444" : root.colorPanel
                                            radius: 4
                                            border.color: muteBtn.checked ? "transparent" : root.colorBorder
                                        }
                                        contentItem: Shape {
                                            anchors.centerIn: parent
                                            width: 12
                                            height: 12
                                            ShapePath {
                                                fillColor: muteBtn.checked ? "#ffffff" : root.colorTextMuted
                                                strokeColor: "transparent"
                                                PathSvg {
                                                    path: "M12 2C6.47 2 2 6.47 2 12s4.47 10 10 10 10-4.47 10-10S17.53 2 12 2zm5 13.59L15.59 17 12 13.41 8.41 17 7 15.59 10.59 12 7 8.41 8.41 7 12 10.59 15.59 7 17 8.41 13.41 12 17 15.59z"
                                                }
                                            }
                                        }
                                        onClicked: globalTrackListModel.toggleMute(index)
                                    }

                                    // Solo Button (SVG)
                                    Button {
                                        id: soloBtn
                                        implicitWidth: 24
                                        implicitHeight: 20
                                        checkable: true
                                        checked: model.isSolo
                                        background: Rectangle {
                                            color: soloBtn.checked ? "#fbbf24" : root.colorPanel
                                            radius: 4
                                            border.color: soloBtn.checked ? "transparent" : root.colorBorder
                                        }
                                        contentItem: Shape {
                                            anchors.centerIn: parent
                                            width: 12
                                            height: 12
                                            ShapePath {
                                                fillColor: soloBtn.checked ? "#1e293b" : root.colorTextMuted
                                                strokeColor: "transparent"
                                                PathSvg {
                                                    path: "M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"
                                                }
                                            }
                                        }
                                        onClicked: globalTrackListModel.toggleSolo(index)
                                    }

                                    // Volume Slider
                                    Slider {
                                        id: volSlider
                                        from: 0
                                        to: 200
                                        value: model.volume
                                        implicitWidth: 60
                                        implicitHeight: 18
                                        onMoved: {
                                            model.volume = value
                                        }
                                        background: Rectangle {
                                            height: 4
                                            color: root.colorBorder
                                            radius: 2
                                            anchors.verticalCenter: parent.verticalCenter
                                            Rectangle {
                                                width: volSlider.visualPosition * parent.width
                                                height: parent.height
                                                color: root.colorAccent
                                                radius: 2
                                            }
                                        }
                                        handle: Rectangle {
                                            x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                                            y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                                            implicitWidth: 10
                                            implicitHeight: 10
                                            radius: 5
                                            color: volSlider.pressed ? root.colorAccent : "#f5f6fa"
                                            border.color: root.colorAccent
                                            border.width: 1
                                        }
                                    }

                                    // Panning Slider
                                    Slider {
                                        id: panSlider
                                        from: -100
                                        to: 100
                                        value: model.panning
                                        implicitWidth: 44
                                        implicitHeight: 18
                                        onMoved: {
                                            model.panning = value
                                        }
                                        background: Rectangle {
                                            height: 4
                                            color: root.colorBorder
                                            radius: 2
                                            anchors.verticalCenter: parent.verticalCenter
                                            Rectangle {
                                                x: Math.min(parent.width / 2, panSlider.visualPosition * parent.width)
                                                width: Math.abs(panSlider.visualPosition - 0.5) * parent.width
                                                height: parent.height
                                                color: "#00F0FF"
                                                radius: 2
                                            }
                                        }
                                        handle: Rectangle {
                                            x: panSlider.leftPadding + panSlider.visualPosition * (panSlider.availableWidth - width)
                                            y: panSlider.topPadding + panSlider.availableHeight / 2 - height / 2
                                            implicitWidth: 8
                                            implicitHeight: 8
                                            radius: 4
                                            color: panSlider.pressed ? "#00F0FF" : "#f5f6fa"
                                            border.color: "#00F0FF"
                                            border.width: 1
                                        }
                                    }
                                }
                            }
                        }

                        // Right Side: Clips & Grid
                        Item {
                            id: gridArea
                            Layout.fillWidth: true
                            height: parent.height

                            ClipListModel {
                                id: trackClipsModel
                                trackId: trackRowItem.trackPtr
                            }

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

                            // Grid Mouse Area to add clips via double click
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton
                                onDoubleClicked: (mouse) => {
                                    var rawTick = xToTick(mouse.x);
                                    var snappedTick = Math.round(rawTick / 192) * 192; // Snap to bar boundary
                                    trackClipsModel.addClip(snappedTick);
                                }
                                onClicked: {
                                    root.selectedTrackIndex = trackRowItem.trackIndex;
                                }
                            }

                            // Rendered Clips
                            Repeater {
                                model: trackClipsModel
                                delegate: Rectangle {
                                    id: clipRect
                                    x: tickToX(model.startTick)
                                    y: 8
                                    width: Math.max(10, tickToX(model.lengthTicks))
                                    height: parent.height - 16
                                    radius: 6
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: trackRowItem.trackColorHex || "#7f39fb" }
                                        GradientStop { position: 1.0; color: Qt.darker(trackRowItem.trackColorHex || "#7f39fb", 1.2) }
                                    }
                                    border.color: root.selectedTrackIndex === trackRowItem.trackIndex ? root.colorAccent : Qt.lighter(trackRowItem.trackColorHex || "#7f39fb", 1.2)
                                    border.width: root.selectedTrackIndex === trackRowItem.trackIndex ? 1.5 : 1

                                    // Clip Title Text
                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 8
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: model.clipName || "MIDI Clip"
                                        color: root.colorText
                                        font.bold: true
                                        font.pixelSize: 10
                                        style: Text.Outline
                                        styleColor: "#50000000"
                                    }

                                    // Drag-to-move and Right-click context menu
                                    MouseArea {
                                        id: clipDragArea
                                        anchors.fill: parent
                                        anchors.rightMargin: 10 // Leave 10px on the right edge for resizing
                                        drag.target: parent
                                        drag.axis: Drag.XAxis
                                        drag.minimumX: 0
                                        drag.maximumX: gridArea.width - clipRect.width

                                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                                        onPressed: (mouse) => {
                                            if (mouse.button === Qt.RightButton) {
                                                clipContextMenu.open();
                                            } else {
                                                root.selectedTrackIndex = trackRowItem.trackIndex;
                                            }
                                        }

                                        onReleased: {
                                            var newTick = xToTick(clipRect.x);
                                            var snappedTick = Math.round(newTick / 12) * 12; // Snap to 16th note
                                            trackClipsModel.moveClip(model.clipIndex, snappedTick);
                                            clipRect.x = tickToX(snappedTick);
                                        }

                                        hoverEnabled: true
                                        onEntered: clipRect.opacity = 0.9
                                        onExited: clipRect.opacity = 1.0
                                    }

                                    // Drag-to-resize handle (right edge of the clip)
                                    Rectangle {
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        width: 10
                                        color: "transparent"

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.SizeHorCursor
                                            
                                            property int startMouseX: 0
                                            property int startWidth: 0

                                            onPressed: (mouse) => {
                                                startMouseX = mouse.x;
                                                startWidth = clipRect.width;
                                                root.selectedTrackIndex = trackRowItem.trackIndex;
                                            }

                                            onPositionChanged: (mouse) => {
                                                if (pressed) {
                                                    var deltaX = mouse.x - startMouseX;
                                                    var newWidth = Math.max(10, startWidth + deltaX);
                                                    clipRect.width = newWidth;
                                                }
                                            }

                                            onReleased: {
                                                var newLengthTicks = xToTick(clipRect.width);
                                                var snappedLengthTicks = Math.round(newLengthTicks / 12) * 12; // Snap to 16th note
                                                if (snappedLengthTicks < 12) snappedLengthTicks = 12;
                                                trackClipsModel.resizeClip(model.clipIndex, snappedLengthTicks);
                                                clipRect.width = tickToX(snappedLengthTicks);
                                            }
                                        }
                                    }

                                    Menu {
                                        id: clipContextMenu
                                        MenuItem {
                                            text: "Delete Clip"
                                            onTriggered: trackClipsModel.deleteClip(model.clipIndex)
                                        }
                                    }
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
