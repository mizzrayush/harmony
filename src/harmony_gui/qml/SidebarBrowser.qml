import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
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

                Text {
                    text: "🔍"
                    color: root.colorTextMuted
                    font.pixelSize: 12
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

                        Text {
                            text: model.icon
                            font.pixelSize: 14
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
