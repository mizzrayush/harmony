import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes
import Harmony

Rectangle {
    id: browserRoot
    color: root.colorPanel
    
    BrowserModel {
        id: browserModel
        category: categoryRow.activeTab
        filter: searchField.text
    }

    // Right border separator
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: root.colorBorder
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12
        anchors.margins: 12

        // Search Bar Container
        Rectangle {
            Layout.fillWidth: true
            height: 32
            color: root.colorPanelLight
            border.color: root.colorBorder
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 6

                Shape {
                    width: 14
                    height: 14
                    ShapePath {
                        fillColor: root.colorTextMuted
                        strokeColor: "transparent"
                        PathSvg {
                            path: "M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"
                        }
                    }
                }

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Search library...")
                    placeholderTextColor: root.colorTextMuted
                    color: root.colorText
                    font.pixelSize: 12
                    background: null
                    verticalAlignment: TextInput.AlignVCenter
                }
            }
        }

        // Category Selectors
        RowLayout {
            id: categoryRow
            Layout.fillWidth: true
            spacing: 4
            
            property int activeTab: 0

            Repeater {
                model: ["Plugins", "Samples", "Projects"]
                delegate: Button {
                    id: tabBtn
                    Layout.fillWidth: true
                    implicitHeight: 26
                    
                    background: Rectangle {
                        color: categoryRow.activeTab === index ? root.colorAccent : "transparent"
                        radius: 4
                        border.color: categoryRow.activeTab === index ? "transparent" : root.colorBorder
                        border.width: 1
                    }

                    contentItem: Text {
                        text: modelData
                        color: categoryRow.activeTab === index ? root.colorText : root.colorTextMuted
                        font.pixelSize: 10
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: categoryRow.activeTab = index
                }
            }
        }

        // Browser Library List
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: libraryList
                anchors.fill: parent
                spacing: 2
                model: browserModel

                delegate: ItemDelegate {
                    id: itemDelegate
                    width: libraryList.width
                    height: 36
                    
                    background: Rectangle {
                        color: itemDelegate.hovered ? root.colorPanelLight : "transparent"
                        radius: 4
                    }

                    contentItem: RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 10

                        Shape {
                            width: 16
                            height: 16
                            ShapePath {
                                fillColor: root.colorAccent
                                strokeColor: "transparent"
                                PathSvg {
                                    path: {
                                        if (model.type === "plugin") {
                                            return "M16 7h-1V6c0-1.1-.9-2-2-2h-3c-1.1 0-2 .9-2 2v1H7c-1.1 0-2 .9-2 2v6c0 2.21 1.79 4 4 4h1v2h2v-2h2v2h2v-2h1c2.21 0 4-1.79 4-4V9c0-1.1-.9-2-2-2z"
                                        } else if (model.type === "sample") {
                                            return "M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"
                                        } else if (model.type === "project") {
                                            return "M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H6v-2h8v2zm3-4H6v-2h11v2zm0-4H6V7h11v2z"
                                        } else {
                                            return "M10 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2h-8l-2-2z"
                                        }
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true

                            Text {
                                text: model.name
                                color: root.colorText
                                font.pixelSize: 12
                                font.bold: true
                                elide: Text.ElideRight
                            }
                            Text {
                                text: model.desc
                                color: root.colorTextMuted
                                font.pixelSize: 9
                                elide: Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        propagateComposedEvents: true
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.RightButton && model.type === "plugin") {
                                itemMenu.open()
                            }
                        }
                        onDoubleClicked: {
                            if (model.type === "plugin") {
                                globalTrackListModel.addInstrumentTrack(model.path)
                            }
                        }
                    }

                    Menu {
                        id: itemMenu
                        MenuItem {
                            text: "Send to new instrument track"
                            onTriggered: {
                                globalTrackListModel.addInstrumentTrack(model.path)
                            }
                        }
                    }
                }
            }
        }
    }
}
